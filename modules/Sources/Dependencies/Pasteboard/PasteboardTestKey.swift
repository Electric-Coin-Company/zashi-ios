//
//  PasteboardTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension PasteboardClient: TestDependencyKey {
    public static let testValue = Self(
        setString: XCTUnimplemented("\(Self.self).setString"),
        getString: XCTUnimplemented("\(Self.self).getString", placeholder: "".redacted)
    )
    
    private struct TestPasteboard {
        static var general = TestPasteboard()
        var string: String?
    }
    
    public static let testPasteboard = Self(
        setString: { TestPasteboard.general.string = $0.data },
        getString: { TestPasteboard.general.string?.redacted }
    )
}
