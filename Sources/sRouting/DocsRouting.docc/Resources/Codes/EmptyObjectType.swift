//
//  EmptyObjectType.swift
//  Bookie
//
//  Created by ThangKieu on 7/7/21.
//

import Foundation

protocol EmptyObjectType {
    
    static var empty: Self { get }
    
    var isEmptyObject: Bool { get }
}
