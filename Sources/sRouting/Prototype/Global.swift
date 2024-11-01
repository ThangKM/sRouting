//
//  Global.swift
//
//
//  Created by Thang Kieu on 20/8/24.
//

import SwiftUI

internal typealias SignalChange = Bool

public typealias WithTransaction =  @MainActor @Sendable () -> SwiftUI.Transaction

public typealias GetAlert = @Sendable () -> Alert
#if canImport(UIKit)
public typealias GetActionSheet = @Sendable () -> ActionSheet
#endif
