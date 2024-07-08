//
//  SupportDataGeneratorTestKey.swift
//  secant
//
//  Created by Michal Fousek on 28.02.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension SupportDataGeneratorClient: TestDependencyKey {
    public static let testValue = Self(
        generate: unimplemented("\(Self.self).generate", placeholder: SupportData(toAddress: "", subject: "", message: ""))
    )
}

extension SupportDataGeneratorClient {
    public static let noOp = Self(
        generate: { SupportData(toAddress: "", subject: "", message: "") }
    )
}
