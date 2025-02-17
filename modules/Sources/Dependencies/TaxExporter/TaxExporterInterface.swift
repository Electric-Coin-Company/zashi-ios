//
//  TaxExporterInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-13.
//

import Foundation
import ComposableArchitecture
import Models

extension DependencyValues {
    public var taxExporter: TaxExporterClient {
        get { self[TaxExporterClient.self] }
        set { self[TaxExporterClient.self] = newValue }
    }
}

@DependencyClient
public struct TaxExporterClient {
    public let cointrackerCSVfor: ([TransactionState], String) throws -> URL
}
