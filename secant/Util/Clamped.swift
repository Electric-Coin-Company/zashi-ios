//
//  Clamped.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/20/21.
//
// credits: https://iteo.medium.com/swift-property-wrappers-how-to-use-them-right-77095817d1b
import Foundation

/**
Limits a value to an enclosing range
*/
@propertyWrapper
struct Clamped<Value: Comparable> {
    var value: Value
    let range: ClosedRange<Value>
    var wrappedValue: Value {
        get {
            min(
                max(range.lowerBound, value),
                range.upperBound
            )
        }
        set { value = newValue }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.value = wrappedValue
        self.range = range
    }
}
