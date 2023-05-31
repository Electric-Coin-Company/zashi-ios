//
//  URIParserLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture

extension URIParserClient: DependencyKey {
    public static let liveValue = Self(
        isValidURI: { uri, network in
            URIParser().isValidURI(uri, network: network)
        }
    )
}
