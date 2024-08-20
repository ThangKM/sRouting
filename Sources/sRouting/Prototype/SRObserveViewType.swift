//
//  SRNavObserveViewType.swift
//
//
//  Created by Thang Kieu on 19/8/24.
//

import Foundation
import SwiftUI

public protocol SRObserveViewType {
    associatedtype ObserveContent: View
    
    var path: SRNavigationPath { get }
    var content: () -> ObserveContent { get }
    
    init(path: SRNavigationPath, @ViewBuilder content: @escaping () -> ObserveContent)
}
