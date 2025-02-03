
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private let model_sendable = "ModelSendable"
private let model_sendable_type = "ModelSendableType"
private let model_sendable_ignore = "ModelSendableIgnore"
private let model_sendable_property = "ModelSendableProperty"
private let persistent_model_id = "persistentModelID"
private let attribute_unique = "unique"
private let macro_unique = "Unique"
private let persistent_identifier_type = "PersistentIdentifier"
private let persistent_identifier_property = "persistentIdentifier"
private let persistent_model_sendable = "PersistentModelSendable"
private let asscosicated_sendable_type = "SendableType"

package struct ModelSendableMacro: ExtensionMacro {
    
    static let helper = ParseHelper()
    
    package static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                  attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                                  providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                                  conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                  in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MSMacroError.onlyClass
        }

        // Extract class name
        let originalName = classDecl.name.text
        let validAccessLevel = ["public", "internal", "fileprivate", "private", "package"]
        let accessLevel = classDecl.modifiers.compactMap(\.name.text)
            .first(where: { validAccessLevel.contains($0)}) ?? ""
        
        // Extract custom struct name from macro arguments (if provided)
        let macroArgs = node.arguments?.as(LabeledExprListSyntax.self)
        let customStructName = macroArgs?.first?.expression.as(StringLiteralExprSyntax.self)?.segments.description ?? model_sendable
        
        var structMembers: [DeclSyntax] = []
        var initAssignments: [String] = []
        var updateAssignments: [String] = []
        var uniqueProps: Set<String> = []
        
        initAssignments.append("self.\(persistent_identifier_property) = original.\(persistent_model_id)")
        
        let vardeclPersistentIdentifier: DeclSyntax = "\(raw: accessLevel) let \(raw: persistent_identifier_property): \(raw: persistent_identifier_type)"
        structMembers.append(vardeclPersistentIdentifier)
        
        // Process class members
        for member in classDecl.memberBlock.members {
            
            if let macroDecl = member.decl.as(MacroExpansionDeclSyntax.self), macroDecl.macroName.text.contains(macro_unique) {
                let expressions = macroDecl.arguments.compactMap({ $0.expression.as(ArrayExprSyntax.self) }).filter({ $0.elements.count == 1 })
                let uniqueKeyPaths = expressions.compactMap { $0.elements.first?.expression.as(KeyPathExprSyntax.self)?.components.first?.component.description }
                uniqueProps.formUnion(uniqueKeyPaths)
                continue
            }
            
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  !helper.attributesContains(varDecl.attributes, name: model_sendable_ignore) else {
                continue
            }
            
            //Property is a computed property
            if varDecl.bindings.first?.accessorBlock != nil {
                continue
            }
            
            var varDeclWithoutAttributes = varDecl
            varDeclWithoutAttributes.attributes = []
            
            var vardeclModifier = DeclSyntax(varDeclWithoutAttributes)
            var isReplaceType = false
            var isReplaceTypeOptional = false
            
            // Replace PersistentModel by PersistentModel.SendableType if needed
            if helper.attributesContains(varDecl.attributes, name: model_sendable_property) {
                if let typeAnnotation = varDecl.bindings.first?.typeAnnotation, let nameType = helper.extractTypeName(from: typeAnnotation.type) {
                    var varDescription = varDeclWithoutAttributes.description
                    varDescription = varDescription.replacingOccurrences(of: nameType, with: "\(nameType).\(asscosicated_sendable_type)")
                    vardeclModifier = "\(raw: varDescription)"
                    isReplaceType = true
                    isReplaceTypeOptional = typeAnnotation.type.is(OptionalTypeSyntax.self)
                }
            }
            structMembers.append(vardeclModifier)
            
            guard let binding = varDecl.bindings.first,
                  let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else { continue }
            
            //Initial function body
            if isReplaceType {
                initAssignments.append("self.\(propertyName) = original.\(propertyName)\(isReplaceTypeOptional ? "?" : "").sendable")
            } else {
                initAssignments.append("self.\(propertyName) = original.\(propertyName)")
            }
            
            //Update function body
            guard !helper.attributesContains(varDecl.attributes, name: attribute_unique) else {
                uniqueProps.insert(propertyName)
                continue
            }
            
            guard !uniqueProps.contains(propertyName) else { continue }
            
            guard isReplaceType else {
                updateAssignments.append("self.\(propertyName) = sendable.\(propertyName)")
                continue
            }
            
            guard isReplaceTypeOptional else {
                updateAssignments.append("self.\(propertyName).update(from: sendable.\(propertyName))")
                continue
            }
            
            let updateStatement = """
            if let model = sendable.\(propertyName) {
                self.\(propertyName)?.update(from: model)
            } else {
                self.\(propertyName) = nil
            }
            """
            updateAssignments.append(updateStatement)
        }
        
        // Generate initializer
        let initializerSyntax = """
                fileprivate init(from original: \(originalName)) {
                \(initAssignments.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "\n"))
                }
                """
        
        // Build struct definition
        let structSyntax: DeclSyntax = """
        \(raw: accessLevel) struct \(raw: customStructName): \(raw: persistent_model_sendable) {
        
            \(raw: structMembers.map { $0.trimmedDescription }.joined(separator: "\n"))
        
            \(raw: initializerSyntax)
        }
        """
        let extDecl: DeclSyntax = """
        extension \(raw: type.trimmedDescription): \(raw: model_sendable_type) {
        
        \(raw: structSyntax.description)
        
        \(raw: accessLevel) var sendable: \(raw: customStructName) {
        \(raw: customStructName)(from: self)
        }
        
        \(raw: accessLevel) func update(from sendable: \(raw: customStructName)) {
        assert(sendable.\(raw: persistent_identifier_property) == self.\(raw: persistent_model_id), "Miss match PersistentIdentifier!")
        guard sendable.\(raw: persistent_identifier_property) == self.\(raw: persistent_model_id) else { return }
        \(raw: updateAssignments.map { $0 }.joined(separator: "\n"))
        }
        }
        """
        return [extDecl.cast(ExtensionDeclSyntax.self)]
    }
}

//MARK: - ModelSendableIgnoreMacro
package struct ModelSendableIgnoreMacro: PeerMacro {
    package static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                  providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                  in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

//MARK: - ModelSendablePropertyMacro
package struct ModelSendablePropertyMacro: PeerMacro {
    package static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                  providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                  in context: some SwiftSyntaxMacros.MacroExpansionContext)
    throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}


