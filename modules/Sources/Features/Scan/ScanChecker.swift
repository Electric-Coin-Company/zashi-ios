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

import KeystoneHandler
import KeystoneSDK

public protocol ScanChecker: Equatable {
    var id: Int { get }
    
    func checkQRCode(_ qrCode: String) -> Scan.Action?
}

public struct ZcashAddressScanChecker: ScanChecker, Equatable {
    public let id = 0
    
    public func checkQRCode(_ qrCode: String) -> Scan.Action? {
        @Dependency(\.uriParser) var uriParser
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
        
        if uriParser.isValidURI(qrCode, zcashSDKEnvironment.network.networkType) {
            return .found(qrCode.redacted)
        } else {
            return nil
        }
    }
}

public struct RequestZecScanChecker: ScanChecker, Equatable {
    public let id = 1
    
    public func checkQRCode(_ qrCode: String) -> Scan.Action? {
        @Dependency(\.uriParser) var uriParser
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
        
        if let parserResult = uriParser.checkRP(qrCode) {
            return .foundRP(parserResult)
        } else {
            return nil
        }
    }
}

public struct KeystoneScanChecker: ScanChecker, Equatable {
    public let id = 2
    
    public func checkQRCode(_ qrCode: String) -> Scan.Action? {
        @Dependency(\.keystoneHandler) var keystoneHandler
        
        if let result = keystoneHandler.decodeQR(qrCode) {
            if let resultUR = result.ur, result.progress == 100 {
                if let zcashAccounts = try? KeystoneSDK().parseZcashAccounts(ur: resultUR) {
                    return .foundZA(zcashAccounts)
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
}

public struct ScanCheckerWrapper: Equatable {
    let checker: any ScanChecker

    public static let zcashAddressScanChecker = ScanCheckerWrapper(ZcashAddressScanChecker())
    public static let requestZecScanChecker = ScanCheckerWrapper(RequestZecScanChecker())
    public static let keystoneScanChecker = ScanCheckerWrapper(KeystoneScanChecker())

    static public func == (lhs: ScanCheckerWrapper, rhs: ScanCheckerWrapper) -> Bool {
        return lhs.checker.id == rhs.checker.id
    }
    
    public init(_ checker: any ScanChecker) {
        self.checker = checker
    }
}
