//
//  ClearBackgroundView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI

/// Purpose of this utility is to solve background transparency of the view used for example in `.fullScreenCover`.
/// Usually used for the modal full screen views with semi-transparent backgrounds.
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        /// Wrapped in the dispatch queue to achieve the background clearance,
        /// it doesn't work otherwise (opaque background instead of fully transparent).
        /// Comes from https://stackoverflow.com/a/66925883
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
