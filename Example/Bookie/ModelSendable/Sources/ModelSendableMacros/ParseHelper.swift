
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct ParseHelper {
    
    func attributesContains(_ attributes: AttributeListSyntax, name: String) -> Bool {
        attributes.contains(where: { $0.description.contains(name) })
    }
    
    func extractTypeName(from typeSyntax: TypeSyntax) -> String? {
        if let identifier = typeSyntax.as(IdentifierTypeSyntax.self) {
            return identifier.name.text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let optionalType = typeSyntax.as(OptionalTypeSyntax.self) {
            return extractTypeName(from: optionalType.wrappedType)
        } else if let arrayType = typeSyntax.as(ArrayTypeSyntax.self) {
            return extractTypeName(from: arrayType.element)
        }
        return nil
    }
}
