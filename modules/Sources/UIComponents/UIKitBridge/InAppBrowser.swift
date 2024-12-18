//
//  InAppBrowser.swift
//
//
//  Created by Lukáš Korba on 06-28-2024.
//

import Foundation
import SwiftUI
import SafariServices

public struct InAppBrowserView: UIViewControllerRepresentable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<InAppBrowserView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<InAppBrowserView>) {
    }
}
