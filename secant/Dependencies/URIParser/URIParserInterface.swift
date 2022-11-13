//
//  URIParserClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var uriParser: URIParserClient {
        get { self[URIParserClient.self] }
        set { self[URIParserClient.self] = newValue }
    }
}

struct URIParserClient {
    var isValidURI: (String) throws -> Bool
}
        
