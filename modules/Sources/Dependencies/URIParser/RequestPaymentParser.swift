//
//  RequestPaymentParser.swift
//
//
//  Created by Lukáš Korba on 24.05.2024.
//

import Foundation
import Models

public struct RequestPaymentParser {
    public enum URIParserError: Error { }
    
    public func checkRP(_ dataStr: String) -> RPData? {
        let decoder = PropertyListDecoder()
        if let data = Data(base64Encoded: dataStr, options: .ignoreUnknownCharacters) {
            return try? decoder.decode(RPData.self, from: data)
        }
        
        return nil
    }
}
