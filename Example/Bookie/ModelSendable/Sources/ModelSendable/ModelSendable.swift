
import Foundation
import SwiftData

//MARK: - Macros
@attached(extension, conformances: ModelSendableType, names: arbitrary, named(sendable))
public macro ModelSendable(name: String? = nil) = #externalMacro(module: "ModelSendableMacros", type: "ModelSendableMacro")

@attached(peer)
public macro ModelSendableIgnore() = #externalMacro(module: "ModelSendableMacros", type: "ModelSendableIgnoreMacro")

@attached(peer)
public macro ModelSendableProperty() = #externalMacro(module: "ModelSendableMacros", type: "ModelSendablePropertyMacro")

//MARK: - Macros Types
public protocol PersistentModelSendable: Sendable {
    var persistentIdentifier: PersistentIdentifier { get }
}

public protocol ModelSendableType {
    
    associatedtype SendableType: PersistentModelSendable
    
    var sendable: SendableType { get }
    func update(from sendable: SendableType)
}

extension ModelSendableType where Self: PersistentModel {
    
    public var persistentIdentifier: PersistentIdentifier {
        persistentModelID
    }
}

//MARK: - Helpers
extension Array where Element: ModelSendableType, Element: PersistentModel {
    
    public mutating func update(from sendable: [Element.SendableType]) {
        
        guard !sendable.isEmpty else {
            self.removeAll()
            return
        }
        
        let validIds = sendable.map(\.persistentIdentifier)
        let validModels = self.filter({ validIds.contains($0.persistentIdentifier)})
        for element in validModels {
            guard let updateModel = sendable.first(where: { $0.persistentIdentifier == element.persistentIdentifier })
            else { continue }
            element.update(from: updateModel)
        }
        self = validModels
    }

    public var sendable: [Element.SendableType] {
        self.map(\.sendable)
    }
}
