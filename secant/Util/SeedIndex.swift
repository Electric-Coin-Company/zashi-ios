//
//  SeedIndex.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.02.2022.
//

@propertyWrapper
struct SeedIndex {
    var wrappedValue: Int {
        didSet { wrappedValue = min(24, max(1, wrappedValue)) }
    }
}
