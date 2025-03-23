//
//  BookPersistent+Queries.swift
//  Bookie
//
//  Created by Thang Kieu on 14/2/25.
//

import SwiftData
import Foundation

//MARK: - FetchDescriptors
extension BookPersistent {
    
    struct Query: DatabaseQuery {
        
        typealias Model = BookPersistent
        
        func fetchByBookId(_ id: Int) -> FetchDescriptor<BookPersistent> {
            .init(predicate: #Predicate { $0.bookId == id })
        }
        
        func searchBook(query: String) -> FetchDescriptor<BookPersistent> {
            var descriptor = FetchDescriptor<BookPersistent>(predicate: #Predicate { $0.name.localizedStandardContains(query)
                || $0.author.localizedStandardContains(query) })
            descriptor.fetchLimit = 20
            descriptor.sortBy = [.init(\.bookId, order: .forward)]
            return descriptor
        }
        
        func fetchByBookIds(_ ids: Set<Int>) -> FetchDescriptor<BookPersistent> {
            .init(predicate: #Predicate { ids.contains($0.bookId) })
        }
        
        func existBookIds(_ ids: Set<Int>) -> FetchDescriptor<BookPersistent> {
            var descriptor = FetchDescriptor<BookPersistent>(predicate: #Predicate { ids.contains($0.bookId) })
            descriptor.propertiesToFetch = [\.bookId]
            return descriptor
        }
    }
}
