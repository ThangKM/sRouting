//
//  OnShowErrorModifier.swift
//  Bookie
//
//  Created by Thang Kieu on 27/4/25.
//

import SwiftUI

public struct DisplayableError: LocalizedError, Identifiable, Hashable {
    
    public let id: String
    public var errorDescription: String? {
        message
    }
    let message: String
    
    public init(message: String) {
        self.message = message
        self.id = UUID().uuidString
    }
}

struct OnShowErrorModifier: ViewModifier {
    
    @State private var isPresentAlert: Bool = false
    @Binding var error: DisplayableError?
    
    private var errorMessage: String {
        error?.message ?? "Something went wrong."
    }
    
    func body(content: Content) -> some View {
        content
            .alert("", isPresented: $isPresentAlert) {
                
            } message: {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.accent)
            }
            .onChange(of: isPresentAlert, { _, newValue in
                guard !newValue else { return }
                error = .none
            })
            .onChange(of: error) { _, newValue in
                guard newValue != nil && !isPresentAlert else { return }
                self.isPresentAlert = true
            }
    }
}

extension View {
    public func onShowError(_ error: Binding<DisplayableError?>) -> some View {
        modifier(OnShowErrorModifier(error: error))
    }
}
