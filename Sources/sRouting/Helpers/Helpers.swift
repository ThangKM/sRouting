//
//  Helpers.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation

struct Helpers {
    
    static func navigationStoredPath(for route: some SRRoute) -> String {
        String(describing: type(of: route)) + "." + route.formatedPath
    }
}

