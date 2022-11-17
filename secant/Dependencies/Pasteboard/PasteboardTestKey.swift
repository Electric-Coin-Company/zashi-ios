//
//  PasteboardTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension PasteboardClient: TestDependencyKey {
    static let testValue = Self(
        setString: XCTUnimplemented("\(Self.self).setString"),
        getString: XCTUnimplemented("\(Self.self).getString", placeholder: "")
    )
    
    private struct TestPasteboard {
        static var general = TestPasteboard()
        var string: String?
    }
    
    static let testPasteboard = Self(
        setString: { TestPasteboard.general.string = $0 },
        getString: { TestPasteboard.general.string }
    )
}
