//
//  URIParserClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var uriParser: URIParserClient {
        get { self[URIParserClient.self] }
        set { self[URIParserClient.self] = newValue }
    }
}

public struct URIParserClient {
    public var isValidURI: (String, NetworkType) -> Bool
}
        
