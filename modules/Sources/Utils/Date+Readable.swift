//
//  Date+Readable.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation

extension Date {
    public static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSSS"
        return formatter
    }()

    public static let humanReadableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    public func timestamp() -> String {
        return String(format: "%@", Date.timestampFormatter.string(from: self))
    }
    
    public func asHumanReadable() -> String {
        return Date.humanReadableFormatter.string(from: self)
    }
}
