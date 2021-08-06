//
//  Router.swift
//  secant
//
//  Created by Francisco Gindre on 8/5/21.
//

import Foundation
import SwiftUI

public protocol Router: ObservableObject {
    associatedtype ViewOutput: View
    
    func rootView() -> ViewOutput
}
