//
//  UInt+SuperscriptText.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/20/21.
//

import Foundation

extension Int {
    private func toScalarSuperscript() -> String {
        precondition(self >= 0 && self <= 9)
        return [
            "\u{2070}", // 0
            "\u{00B9}", // 1
            "\u{00B2}", // 2
            "\u{00B3}", // 3
            "\u{2074}", // 4
            "\u{2075}", // 5
            "\u{2076}", // 6
            "\u{2077}", // 7
            "\u{2078}", // 8
            "\u{2079}" // 9
        ][Int(self)]
    }

    /**
    Returns a superscript string representation this unsigned integer using Unicode Scalars
    */
    var superscriptRepresentation: String {
        precondition(self >= 0)
        var number = self
        var superscript = ""
        repeat {
            superscript = (number % 10).toScalarSuperscript() + superscript
            number /= 10
        } while number > 0
        return superscript
    }
}
