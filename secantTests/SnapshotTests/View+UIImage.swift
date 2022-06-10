//
//  View+UIImage.swift
//  secantTests
//
//  Created by Lukáš Korba on 10.06.2022.
//

import XCTest
import SwiftUI

extension XCTestCase {
    func addAttachments<Content: View>(name: String = #function, _ view: Content) {
        view.attachments(name).forEach { add($0) }
    }
}

extension View {
    func attachments(_ name: String) -> [XCTAttachment] {
        [attachment(name), attachment(name, .dark)]
    }

    func attachment(_ fileName: String, _ colorScheme: ColorScheme = .light) -> XCTAttachment {
        let colorSchemePostfix = colorScheme == .light ? "\(fileName)_light" : "\(fileName)_dark"
        let trimTest = colorSchemePostfix.replacingOccurrences(of: "test", with: "")
        let imageName = trimTest.replacingOccurrences(of: "()", with: "")
        let rect = UIScreen.main.bounds
        
        let viewHelper = self
            .environment(\.colorScheme, colorScheme)
            .frame(width: rect.width, height: rect.height, alignment: .center)
        
        guard let image = viewHelper.asUiImage() else {
            return XCTAttachment(string: "\(imageName)_SnapshotFailed")
        }

        let attachment = XCTAttachment(image: image)
        attachment.name = imageName
        attachment.lifetime = .keepAlways
        return attachment
    }
    
    func asUiImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        
        if let view = controller.view {
            let contentSize = view.intrinsicContentSize
            view.bounds = CGRect(origin: .zero, size: contentSize)
            view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: contentSize)
            let uiImage = renderer.image { _ in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            return uiImage
        }
        
        return nil
    }
}
