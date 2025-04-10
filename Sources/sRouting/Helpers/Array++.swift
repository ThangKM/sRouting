//
//  Array++.swift
//  sRouting
//
//  Created by Thang Kieu on 10/4/25.
//

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
