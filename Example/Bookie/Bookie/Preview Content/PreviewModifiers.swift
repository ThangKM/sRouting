//
//  PreviewModifiers.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import SwiftUI
import SwiftData



@available(iOS 18.0, *)
struct HomeStatePreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> HomeScreen.HomeState {
        let state = HomeScreen.HomeState()
        state.replaceBooks(books: MockBookService.shared.books)
        return state
    }
    
    func body(content: Content, context: HomeScreen.HomeState) -> some View {
        content.environment(context)
    }
    
}

@available(iOS 18.0, *)
struct DetailStatePreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> BookDetailScreen.DetailState {
        let state = BookDetailScreen.DetailState(book: MockBookService.shared.book)
        return state
    }
    
    func body(content: Content, context: BookDetailScreen.DetailState) -> some View {
        content.environment(context)
    }
    
}


@available(iOS 18.0, *)
struct PersistentContainerPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let container = DatabaseProvider.shared.container
        try await makeMockData(container: container)
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
    
    @DatabaseActor
    static private func makeMockData(container: ModelContainer) async throws {
        let books = MockBookService.shared.books
        let models = books.map({ BookPersistent(sendable: $0) })
        try await databaseInsertTransaction(models: models, useContext: .init(container))
    }
}
