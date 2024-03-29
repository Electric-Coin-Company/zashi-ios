//
//  UserPreferencesStorage.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/18/2022.
//

import Foundation
import UserDefaults

/// Live implementation of the `UserPreferences` using User Defaults
/// according to https://developer.apple.com/documentation/foundation/userdefaults
/// the UserDefaults class is thread-safe.
public struct UserPreferencesStorage {
    public enum Constants: String, CaseIterable {
        case zcashActiveAppSessionFrom
        case zcashCurrency
        case zcashFiatConverted
        case zcashRecoveryPhraseTestCompleted
        case zcashSessionAutoshielded
        case zcashUserOptedOutOfCrashReporting
    }
    
    /// Default values for all preferences in case there is no value stored (counterparts to `Constants`)
    private let appSessionFrom: TimeInterval
    private let convertedCurrency: String
    private let fiatConvertion: Bool
    private let recoveryPhraseTestCompleted: Bool
    private let sessionAutoshielded: Bool
    private let userOptedOutOfCrashReporting: Bool
    
    private let userDefaults: UserDefaultsClient
    
    public init(
        appSessionFrom: TimeInterval,
        convertedCurrency: String,
        fiatConvertion: Bool,
        recoveryPhraseTestCompleted: Bool,
        sessionAutoshielded: Bool,
        userOptedOutOfCrashReporting: Bool,
        userDefaults: UserDefaultsClient
    ) {
        self.appSessionFrom = appSessionFrom
        self.convertedCurrency = convertedCurrency
        self.fiatConvertion = fiatConvertion
        self.recoveryPhraseTestCompleted = recoveryPhraseTestCompleted
        self.sessionAutoshielded = sessionAutoshielded
        self.userOptedOutOfCrashReporting = userOptedOutOfCrashReporting
        self.userDefaults = userDefaults
    }
    
    /// From when the app is on and uninterrupted
    public var activeAppSessionFrom: TimeInterval {
        getValue(forKey: Constants.zcashActiveAppSessionFrom.rawValue, default: appSessionFrom)
    }
    
    public func setActiveAppSessionFrom(_ timeInterval: TimeInterval) async {
        await setValue(timeInterval, forKey: Constants.zcashActiveAppSessionFrom.rawValue)
    }

    /// What is the set up currency
    public var currency: String {
        getValue(forKey: Constants.zcashCurrency.rawValue, default: convertedCurrency)
    }
    
    public func setCurrency(_ string: String) async {
        await setValue(string, forKey: Constants.zcashCurrency.rawValue)
    }

    /// Whether the fiat conversion is on/off
    public var isFiatConverted: Bool {
        getValue(forKey: Constants.zcashFiatConverted.rawValue, default: fiatConvertion)
    }

    public func setIsFiatConverted(_ bool: Bool) async {
        await setValue(bool, forKey: Constants.zcashFiatConverted.rawValue)
    }

    /// Whether user finished recovery phrase backup test
    public var isRecoveryPhraseTestCompleted: Bool {
        getValue(forKey: Constants.zcashRecoveryPhraseTestCompleted.rawValue, default: recoveryPhraseTestCompleted)
    }

    public func setIsRecoveryPhraseTestCompleted(_ bool: Bool) async {
        await setValue(bool, forKey: Constants.zcashRecoveryPhraseTestCompleted.rawValue)
    }

    /// Whether the user has been autoshielded in the running session
    public var isSessionAutoshielded: Bool {
        getValue(forKey: Constants.zcashSessionAutoshielded.rawValue, default: sessionAutoshielded)
    }

    public func setIsSessionAutoshielded(_ bool: Bool) async {
        await setValue(bool, forKey: Constants.zcashSessionAutoshielded.rawValue)
    }

    /// Whether the user has opted out of crash reporting
    public var isUserOptedOutOfCrashReporting: Bool {
        getValue(forKey: Constants.zcashUserOptedOutOfCrashReporting.rawValue, default: false)
    }

    public func setIsUserOptedOutOfCrashReporting(_ bool: Bool) async {
        await setValue(bool, forKey: Constants.zcashUserOptedOutOfCrashReporting.rawValue)
    }

    /// Use carefully: Deletes all user preferences from the User Defaults
    public func removeAll() {
        for key in Constants.allCases {
            userDefaults.remove(key.rawValue)
        }
    }
}

private extension UserPreferencesStorage {
    func getValue<Value>(forKey: String, default defaultIfNil: Value) -> Value {
        userDefaults.objectForKey(forKey) as? Value ?? defaultIfNil
    }

    func setValue<Value>(_ value: Value, forKey: String) async {
        userDefaults.setValue(value, forKey)
    }
}
