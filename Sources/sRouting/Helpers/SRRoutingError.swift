//
//  SRRoutingError.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import Foundation

public enum SRRoutingError: Error, CustomStringConvertible, CustomNSError {
    
    case unsupportedDecodable

    public static var errorDomain: String { "com.srouting" }
    
    public var errorCode: Int {
        switch self {
        case .unsupportedDecodable:
            -600
        }
    }
    
    public var description: String {
        switch self {
        case .unsupportedDecodable:
            "SRRoute don't support Decodable!"
        }
    }
    
    public var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: description]
    }
}
