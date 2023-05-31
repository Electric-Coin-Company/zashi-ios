//
//  URIParser.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import DerivationTool

public struct URIParser {
    enum URIParserError: Error { }
    
    private let derivationTool: DerivationToolClient
    
    init(derivationTool: DerivationToolClient) {
        self.derivationTool = derivationTool
    }

    func isValidURI(_ uri: String) -> Bool {
        derivationTool.isZcashAddress(uri, TargetConstants.zcashNetwork.networkType)
    }
}
