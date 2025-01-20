//
//  PreviewModifiers.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import SwiftUI
import SwiftData

@available(iOS 18.0, *)
struct MockBookPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> MockBookService {
        MockBookService()
    }
    
    func body(content: Content, context: MockBookService) -> some View {
        content.environment(context)
    }
    
}

@available(iOS 18.0, *)
struct HomeStatePreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> HomeScreen.HomeState {
        let state = HomeScreen.HomeState()
        state.updateAllBooks(books: MockBookService().books)
        return state
    }
    
    func body(content: Content, context: HomeScreen.HomeState) -> some View {
        content.environment(context)
    }
    
}

@available(iOS 18.0, *)
struct DetailStatePreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> BookDetailScreen.DetailState {
        let state = BookDetailScreen.DetailState(book: MockBookService().books.first ?? .empty)
        return state
    }
    
    func body(content: Content, context: BookDetailScreen.DetailState) -> some View {
        content.environment(context)
    }
    
}


@available(iOS 18.0, *)
struct PersistentContainerPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let container = Database.shared.container
        try await makeMockData(container: container)
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
    
    @PersistentActor
    static private func makeMockData(container: ModelContainer) async throws {
        let books = MockBookService().books
        let models = books.map({ BookPersistent(book: $0) })
        try await persistentWriteTransaction(models: models, useContext: .init(container))
    }
}
