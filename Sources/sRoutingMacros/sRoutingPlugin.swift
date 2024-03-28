//
//  sRoutingPlugin.swift
//
//
//  Created by Thang Kieu on 18/03/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct sRoutingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RouterMacro.self
    ]
}
