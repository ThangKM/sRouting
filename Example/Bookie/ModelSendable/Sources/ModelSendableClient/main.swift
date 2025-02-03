import ModelSendable
import Foundation
import SwiftData

@Model @ModelSendable
final class Metadata {
    var type: String
    
    init(type: String) {
        self.type = type
    }
}

enum Status: Int, Codable {
    case active
    case inactive
}

struct ComplexStruct: Codable {
    var name: String
}


@available(macOS 15, *)
@Model @ModelSendable(name: "BookModel")
final class BookPersistent {
    
    #Unique<BookPersistent>([\.bookId], [\.name, \.author])
    
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
    
    var persistentId: PersistentIdentifier {
        persistentModelID
    }
    
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
