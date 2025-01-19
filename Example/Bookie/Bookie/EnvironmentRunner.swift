//
//  EnvironmentRunner.swift
//  Bookie
//
//  Created by Thang Kieu on 20/1/25.
//

import Foundation


enum EnvironmentRunner: Int {
    case production
    case development
    case livePreview
}

extension EnvironmentRunner {
     static var current: EnvironmentRunner {
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
        else { return .livePreview }
        #if RELEASE
         return .production
         #else
         return .development
         #endif
    }
}
