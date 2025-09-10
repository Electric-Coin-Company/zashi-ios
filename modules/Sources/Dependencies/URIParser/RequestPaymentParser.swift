//
//  RequestPaymentParser.swift
//
//
//  Created by Lukáš Korba on 24.05.2024.
//

import Foundation
import Models
import ZcashPaymentURI
import ZcashLightClientKit

public struct RequestPaymentParser {
    let network: NetworkType 

    public enum URIParserError: Error { }

    public func checkRP(_ dataStr: String) -> ParserResult? {
        try? ZIP321.request(from: dataStr, context: ParserContext.from(networkType: network))
    }
}

