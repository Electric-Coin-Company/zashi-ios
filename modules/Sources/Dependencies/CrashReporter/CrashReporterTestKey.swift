//
//  CrashReporterTestKey.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension CrashReporterClient: TestDependencyKey {
    public static let testValue = Self(
        configure: XCTUnimplemented("\(Self.self).configure"),
        testCrash: XCTUnimplemented("\(Self.self).testCrash"),
        optIn: XCTUnimplemented("\(Self.self).optIn"),
        optOut: XCTUnimplemented("\(Self.self).optOut")
    )
}

extension CrashReporterClient {
    public static let noOp = Self(
        configure: { _ in },
        testCrash: { },
        optIn: { },
        optOut: { }
    )
}
