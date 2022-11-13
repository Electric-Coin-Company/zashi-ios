//
//  URIParserLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture

extension URIParserClient: DependencyKey {
    static let liveValue = URIParserClient.live()
    
    static func live(uriParser: URIParser = URIParser(derivationTool: .live())) -> Self {
        Self(
            isValidURI: { uri in
                try uriParser.isValidURI(uri)
            }
        )
    }
}
