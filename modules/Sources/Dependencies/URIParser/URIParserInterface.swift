//
//  URIParserClient.swift
//  Zashi
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Models
import ZcashPaymentURI

extension DependencyValues {
    public var uriParser: URIParserClient {
        get { self[URIParserClient.self] }
        set { self[URIParserClient.self] = newValue }
    }
}

@DependencyClient
public struct URIParserClient {
    public var isValidURI: (String, NetworkType) -> Bool = { _, _ in false }
    public var checkRP: (String) -> ParserResult? = { _ in nil }
}
        
