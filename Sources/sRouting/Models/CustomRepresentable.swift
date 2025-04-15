//
//  IntRawRepresentable.swift
//  sRouting
//
//  Created by Thang Kieu on 10/4/25.
//

public protocol IntRawRepresentable: RawRepresentable, CaseIterable, Sendable
where RawValue == Int { }

extension IntRawRepresentable {
    public var intValue: Int { rawValue }
}

public protocol StringRawRepresentable: RawRepresentable, CaseIterable, Sendable
where RawValue == String { }

extension StringRawRepresentable {
    public var stringValue: String { rawValue }
}
