//
//  Array+Chunked.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
