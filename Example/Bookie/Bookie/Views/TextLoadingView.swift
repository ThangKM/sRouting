//
//  TextLoadingAnimator.swift
//  Bookie
//
//  Created by Thang Kieu on 21/1/25.
//

import SwiftUI

struct TextLoadingView: View {
    
    let isLoading: Bool
    let text: String
    
    private let resource = LoadingResource()
    
    var body: some View {
        if isLoading {
            TimelineView(.animation(minimumInterval: 0.5, paused: false)) { context in
                resource.inscreaseIndex()
                return Text(resource.text)
            }
        } else {
            Text(text)
        }
    }
}

fileprivate class LoadingResource {
    
    private let loadingText: [String] = ["Loading", "Loading.", "Loading..", "Loading..."]
    
    var text: String {
        loadingText[index]
    }
    
    private var index: Int = -1
    
    func inscreaseIndex() {
        index += 1
        index = index > 3 ? 0 : index
    }
}
