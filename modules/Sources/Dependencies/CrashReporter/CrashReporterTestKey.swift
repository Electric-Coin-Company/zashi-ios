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
        configure: unimplemented("\(Self.self).configure", placeholder: {}()),
        testCrash: unimplemented("\(Self.self).testCrash", placeholder: {}()),
        optIn: unimplemented("\(Self.self).optIn", placeholder: {}()),
        optOut: unimplemented("\(Self.self).optOut", placeholder: {}())
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
