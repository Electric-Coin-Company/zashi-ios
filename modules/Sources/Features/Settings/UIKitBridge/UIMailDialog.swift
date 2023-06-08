//
//  UIMailDialog.swift
//  secant
//
//  Created by Michal Fousek on 28.02.2023.
//

import Foundation
import MessageUI
import UIKit
import SwiftUI
import SupportDataGenerator

public class UIMailDialog: UIView {
    public var completion: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

extension UIMailDialog {
    public func doInitialSetup(supportData: SupportData, completion: @escaping () -> Void) {
        self.completion = completion
        DispatchQueue.main.async {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self

            // Configure the fields of the interface.
            mailVC.setToRecipients([supportData.toAddress])
            mailVC.setSubject(supportData.subject)
            mailVC.setMessageBody("\n\n\(supportData.message)", isHTML: false)

            let rootVC = UIApplication.shared.connectedScenes
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows.first?.rootViewController

            rootVC?.present(
                mailVC,
                animated: true,
                completion: nil
            )
        }
    }
}

extension UIMailDialog: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: completion)
    }
}

public struct UIMailDialogView: UIViewRepresentable {
    public let supportData: SupportData
    public let completion: () -> Void

    public func makeUIView(context: UIViewRepresentableContext<UIMailDialogView>) -> UIMailDialog {
        let view = UIMailDialog()
        view.doInitialSetup(supportData: supportData, completion: completion)
        return view
    }

    public func updateUIView(_ uiView: UIMailDialog, context: UIViewRepresentableContext<UIMailDialogView>) {
        // We can leave it empty here because the view is just handler how to bridge UIKit's UIActivityViewController
        // presentation into SwiftUI. The view itself is not visible, only instantiated, therefore no updates needed.
    }

    public typealias UIViewType = UIMailDialog
}
