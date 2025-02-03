import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ModelSendableMacros)
import ModelSendableMacros

let testMacros: [String: Macro.Type] = [
    "ModelSendable": ModelSendableMacro.self, "ModelSendableProperty": ModelSendablePropertyMacro.self, "ModelSendableIgnore": ModelSendableIgnoreMacro.self
]

final class ModelSendableMacroTests: XCTestCase {
    func testMacroExpansion() {
        assertMacroExpansion("""
        @Model @ModelSendable(name: "BookModel")
        final class BookPersistent {
            
            #Unique<BookPersistent>([\\.bookId], [\\.name, \\.author])
            
            var bookId: Int
            var name: String
            var imageName: String?
            var author :String
            var bookDescription: String
            var status: Status = Status.inactive
            var rating: Int
            
            @Relationship(deleteRule: .cascade)
            @ModelSendableProperty
            var metadata: Metadata
            
            @ModelSendableProperty
            @Relationship(deleteRule: .nullify)
            var metadatas: [Metadata]?
            
            @Transient @ModelSendableIgnore
            var complexStruct: ComplexStruct?
            
            init(bookId: Int, name: String,
                 imageName: String, author: String,
                 bookDescription: String, rating: Int, status: Status) {
                self.bookId = bookId
                self.name = name
                self.imageName = imageName
                self.author = author
                self.bookDescription = bookDescription
                self.rating = rating
                self.status = status
                self.metadata = Metadata(type: "")
                self.metadatas = []
            }
        }
        """, expandedSource: """
        """, macros: testMacros)
    }
}
#endif
