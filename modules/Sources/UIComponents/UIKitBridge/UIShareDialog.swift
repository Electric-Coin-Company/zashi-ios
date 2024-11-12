//
//  UIShareDialog.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import UIKit
import SwiftUI
import LinkPresentation

public final class ShareableImage: NSObject, UIActivityItemSource {
    private let image: UIImage
    let title: String
    let reason: String

    public init(image: UIImage, title: String, reason: String) {
        self.image = image
        self.title = title
        self.reason = reason
        
        super.init()
    }

    public func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        image
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }

    public func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.iconProvider = NSItemProvider(object: UIImage(named: "ZashiLogo") ?? image)
        metadata.title = title
        metadata.originalURL = URL(fileURLWithPath: reason)
        
        return metadata
    }
}

public final class ShareableMessage: NSObject, UIActivityItemSource {
    let title: String
    let message: String
    let desc: String

    public init(title: String, message: String, desc: String) {
        self.title = title
        self.message = message
        self.desc = desc
        
        super.init()
    }

    public func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        message
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        message
    }

    public func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        if let image = UIImage(named: "ZashiLogo") {
            metadata.iconProvider = NSItemProvider(object: image)
        }
        metadata.title = title
        metadata.originalURL = URL(fileURLWithPath: desc)
        
        return metadata
    }
}

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
