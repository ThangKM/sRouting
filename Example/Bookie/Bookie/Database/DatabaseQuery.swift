//
//  DatabaseQuery.swift
//  Bookie
//
//  Created by Thang Kieu on 14/2/25.
//
import SwiftData
import Foundation

protocol DatabaseQuery: Sendable {
    associatedtype Model: PersistentModel
}

extension DatabaseQuery {
    
    var fetchAll: FetchDescriptor<Model> { .init() }
    
    func fetch(offset: Int, limit: Int, sortBy: [SortDescriptor<Model>]) -> FetchDescriptor<Model> {
        var fetchDescriptor = fetchAll
        fetchDescriptor.fetchOffset = offset
        fetchDescriptor.fetchLimit = limit
        fetchDescriptor.sortBy = sortBy
        return fetchDescriptor
    }
    
    func fetchByIdentifiers(_ identifiers: Set<PersistentIdentifier>) -> FetchDescriptor<Model> {
        .init(predicate: #Predicate { identifiers.contains($0.persistentModelID) })
    }
}
