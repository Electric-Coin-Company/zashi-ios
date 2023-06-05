//
//  UIShareDialog.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import UIKit
import SwiftUI

public class UIShareDialog: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

extension UIShareDialog {
    public func doInitialSetup(activityItems: [Any], completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows.first?.rootViewController?.present(
                activityVC,
                animated: true,
                completion: completion
            )
        }
    }
}

public struct UIShareDialogView: UIViewRepresentable {
    public let activityItems: [Any]
    public let completion: () -> Void

    public init(activityItems: [Any], completion: @escaping () -> Void) {
        self.activityItems = activityItems
        self.completion = completion
    }
    
    public func makeUIView(context: UIViewRepresentableContext<UIShareDialogView>) -> UIShareDialog {
        let view = UIShareDialog()
        view.doInitialSetup(activityItems: activityItems, completion: completion)
        return view
    }
    
    public func updateUIView(_ uiView: UIShareDialog, context: UIViewRepresentableContext<UIShareDialogView>) {
        // We can leave it empty here because the view is just handler how to bridge UIKit's UIActivityViewController
        // presentation into SwiftUI. The view itself is not visible, only instantiated, therefore no updates needed.
    }
    
    public typealias UIViewType = UIShareDialog
}
