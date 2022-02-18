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
        get { value }
        set { value = clamp(value: newValue, range: range) }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.value = wrappedValue
        self.range = range
        
        value = clamp(value: wrappedValue, range: range)
    }
    
    private func clamp(_ value: Value, using range: ClosedRange<Value>) -> Value {
        min(range.upperBound, max(range.lowerBound, wrappedValue))
    }
}
