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
            return .foundAddress(qrCode.redacted)
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
            return .foundRequestZec(parserResult)
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
            if result.progress < 100 {
                return ScanCheckerWrapper.reportCheck(qrCode, progress: result.progress)
            }

            if let resultUR = result.ur, result.progress == 100 {
                if let zcashAccounts = try? KeystoneSDK().parseZcashAccounts(ur: resultUR) {
                    return .foundAccounts(zcashAccounts)
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
}

public struct KeystonePcztScanChecker: ScanChecker, Equatable {
    public let id = 3
    
    public func checkQRCode(_ qrCode: String) -> Scan.Action? {
        @Dependency(\.keystoneHandler) var keystoneHandler
        
        if let result = keystoneHandler.decodeQR(qrCode) {
            if result.progress < 100 {
                return ScanCheckerWrapper.reportCheck(qrCode, progress: result.progress)
            }
            
            if let resultUR = result.ur, result.progress == 100 {
                if let zcashPCZT = try? KeystoneZcashSDK().parseZcashPczt(ur: resultUR) {
                    return .foundPCZT(zcashPCZT)
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
}

public struct SwapStringScanChecker: ScanChecker, Equatable {
    public let id = 4
    
    public func checkQRCode(_ qrCode: String) -> Scan.Action? {
        var stringFound = qrCode
        
        // cut ethereum:
        if stringFound.hasPrefix("ethereum:") {
            stringFound.removeSubrange(stringFound.startIndex..<stringFound.index(stringFound.startIndex, offsetBy: 9))
        }
        
        return .foundString(stringFound)
    }
}

public struct ScanCheckerWrapper: Equatable {
    let checker: any ScanChecker

    public static let zcashAddressScanChecker = ScanCheckerWrapper(ZcashAddressScanChecker())
    public static let requestZecScanChecker = ScanCheckerWrapper(RequestZecScanChecker())
    public static let keystoneScanChecker = ScanCheckerWrapper(KeystoneScanChecker())
    public static let keystonePCZTScanChecker = ScanCheckerWrapper(KeystonePcztScanChecker())
    public static let swapStringScanChecker = ScanCheckerWrapper(SwapStringScanChecker())

    static public func == (lhs: ScanCheckerWrapper, rhs: ScanCheckerWrapper) -> Bool {
        return lhs.checker.id == rhs.checker.id
    }
    
    public init(_ checker: any ScanChecker) {
        self.checker = checker
    }
    
    static func reportCheck(_ qrCode: String, progress: Int) -> Scan.Action {
        var firstNumber: Int?
        var secondNumber: Int?
        let pattern = #"/\d+-(\d+)/"#
        if let match = qrCode.range(of: pattern, options: .regularExpression) {
            let substring = qrCode[match]
            if let secNumber = substring.split(separator: "-").last?.split(separator: "/").first {
                secondNumber = Int(secNumber)
            }
            if let firNumber = substring.split(separator: "-").first?.split(separator: "/").last {
                firstNumber = Int(firNumber)
            }
        }
        
        return .animatedQRProgress(progress, firstNumber, secondNumber)
    }
}
