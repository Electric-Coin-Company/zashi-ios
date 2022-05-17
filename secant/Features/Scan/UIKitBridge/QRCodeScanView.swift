//
//  QRCodeScanView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 16.05.2022.
//

import Foundation
import UIKit
import SwiftUI

struct QRCodeScanView: UIViewRepresentable {
    let rectOfInterest: CGRect
    let onQRScanningDidFail: () -> Void
    let onQRScanningSucceededWithCode: (String) -> Void

    public func makeUIView(context: UIViewRepresentableContext<QRCodeScanView>) -> ScanUIView {
        let view = ScanUIView()
        view.rectOfInterest = rectOfInterest
        view.onQRScanningDidFail = onQRScanningDidFail
        view.onQRScanningSucceededWithCode = onQRScanningSucceededWithCode
        return view
    }
    
    public func updateUIView(_ uiView: ScanUIView, context: UIViewRepresentableContext<QRCodeScanView>) { }
    
    public typealias UIViewType = ScanUIView
}
