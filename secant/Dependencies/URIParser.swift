//
//  URIParser.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import ComposableArchitecture

struct URIParser {
    enum URIParserError: Error { }
    
    private let derivationTool: DerivationToolClient
    
    init(derivationTool: DerivationToolClient) {
        self.derivationTool = derivationTool
    }

    func isValidURI(_ uri: String) throws -> Bool {
        try derivationTool.isValidZcashAddress(uri)
    }
}

private enum URIParserKey: DependencyKey {
    static let liveValue = WrappedURIParser.live()
    static let testValue = WrappedURIParser.live()
}

extension DependencyValues {
    var uriParser: WrappedURIParser {
        get { self[URIParserKey.self] }
        set { self[URIParserKey.self] = newValue }
    }
}
