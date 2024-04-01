//
//  SRWindowTransition.swift
//
//
//  Created by Thang Kieu on 29/03/2024.
//

import Foundation

public struct SRWindowTransition {
    
    private(set) var acception: ((_ aception: Bool) -> Void)?
    private(set) var errorHandler: ((_ error: Error?) -> Void)?
    private(set) var url: URL?
    public private(set) var windowId: String?
    public private(set) var windowValue: (any (Codable & Hashable))?
    
    public init(url: URL, 
                acceoption: ((_ aception: Bool) -> Void)? = .none,
                errorHandler: ((_ error: Error?) -> Void)? = .none) {
        self.url = url
        self.acception = acceoption
        self.errorHandler = errorHandler
    }
    
    public init<C>(windowId: String, value: C) where C: Codable, C: Hashable {
        self.windowId = windowId
        self.windowValue = value
    }
    
    public init<C>(value: C) where C: Codable, C: Hashable {
        self.windowValue = value
    }
    
    public init(windowId: String) {
        self.windowId = windowId
    }
}
