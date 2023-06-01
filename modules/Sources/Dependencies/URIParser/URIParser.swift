//
//  URIParser.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import ZcashLightClientKit
import DerivationTool

public struct URIParser {
    public enum URIParserError: Error { }
    
    public func isValidURI(_ uri: String, network: NetworkType) -> Bool {
        DerivationToolClient.live().isZcashAddress(uri, network)
    }
}
