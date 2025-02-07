//
//  VisualEffectBlur.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-03.
//

import UIKit
import SwiftUI

public struct VisualEffectBlur: UIViewRepresentable {
    public init() {
        
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}
