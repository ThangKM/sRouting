//
//  FetchPagingService.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import Foundation
import SwiftData

@MainActor
final class FetchPagingService<T> where T: PersistentModel {
    
    private(set) var offset: Int = .zero
    
    let limit: Int
    
    let sortBy: [SortDescriptor<T>]
    
    init(offset: Int = .zero, limit: Int = 20, sortBy: [SortDescriptor<T>]) {
        self.offset = offset
        self.limit = limit
        self.sortBy = sortBy
    }
    
    func nextPage() {
        offset += limit
    }
    
    func reset() {
        offset = .zero
    }
}
