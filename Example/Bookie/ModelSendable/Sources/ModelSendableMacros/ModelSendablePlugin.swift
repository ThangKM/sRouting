
import SwiftSyntaxMacros
import SwiftCompilerPlugin
import Foundation

@main
struct PersistentSendablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ModelSendableMacro.self, ModelSendableIgnoreMacro.self, ModelSendablePropertyMacro.self
    ]
}


package enum MSMacroError: Error, CustomStringConvertible, CustomNSError {
    
    case onlyClass
    
    package static var errorDomain: String { "com.persistentsendable.macro" }
    
    package var errorCode: Int {
        switch self {
        case .onlyClass:
            -501
        }
    }
    
    package var description: String {
        switch self {
        case .onlyClass:
            "Only support for class!"
        }
    }
    
    package var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
}
