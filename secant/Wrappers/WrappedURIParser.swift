//
//  WrappedURIParser.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation

struct WrappedURIParser {
    let isValidURI: (String) throws -> Bool
}

extension WrappedURIParser {
    static func live(uriParser: URIParser = URIParser(derivationTool: .live())) -> Self {
        Self(
            isValidURI: { uri in
                try uriParser.isValidURI(uri)
            }
        )
    }
}
        
