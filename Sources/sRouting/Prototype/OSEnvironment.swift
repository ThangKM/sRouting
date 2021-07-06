//
//  OSEnvironment.swift
//  
//
//  Created by ThangKieu on 7/6/21.
//

import Foundation

@frozen enum OSEnvironment: String, CaseIterable {
    
    case iOS
    case tvOS
    case macOS
    
    static var current: Self {
        #if os(macOS)
        return .macOS
        #elseif os(tvOS)
        return .tvOS
        #else
        return .iOS
        #endif
    }
}
