//
//  PreviewModifiers.swift
//  Bookie
//
//  Created by Thang Kieu on 16/1/25.
//

import SwiftUI

@available(iOS 18.0, *)
struct MockBookPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> MockBookData {
        MockBookData()
    }
    
    func body(content: Content, context: MockBookData) -> some View {
        content.environment(context)
    }
    
}

@available(iOS 18.0, *)
struct HomeStatePreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> HomeScreen.HomeState {
        let state = HomeScreen.HomeState()
        state.updateAllBooks(books: MockBookData().books)
        return state
    }
    
    func body(content: Content, context: HomeScreen.HomeState) -> some View {
        content.environment(context)
    }
    
}
