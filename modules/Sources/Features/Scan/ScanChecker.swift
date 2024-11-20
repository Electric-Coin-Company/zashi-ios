//
//  ScanChecker.swift
//  modules
//
//  Created by Lukáš Korba on 2024-11-20.
//

import ComposableArchitecture
import URIParser
import ZcashSDKEnvironment
import ZcashPaymentURI

public protocol ScanChecker: Equatable {
    associatedtype T
    
    func checkQRCode(_ qrCode: String) -> T?
}

public struct ZcashAddressScanChecker: ScanChecker, Equatable {
    public typealias T = Bool
    
    public static let zcashAddressScanChecker = Self()
    
    public func checkQRCode(_ qrCode: String) -> Bool? {
        @Dependency(\.uriParser) var uriParser
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

        return uriParser.isValidURI(qrCode, zcashSDKEnvironment.network.networkType)
    }
}

public struct RequestZecScanChecker: ScanChecker, Equatable {
    public typealias T = ParserResult
    
    public static let requestZecScanChecker = Self()
    
    public func checkQRCode(_ qrCode: String) -> ParserResult? {
        @Dependency(\.uriParser) var uriParser
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

        return uriParser.checkRP(qrCode)
    }
}
