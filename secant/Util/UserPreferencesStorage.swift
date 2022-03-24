//
//  UserPreferencesStorage.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/18/2022.
//

import Foundation

/// Representation of the user preferences stored in the local persistent storage (non-encrypted, no security needed)
protocol UserPreferences {
    /// From when the app is on and uninterrupted
    var activeAppSessionFrom: TimeInterval { get set }
    /// What is the set up currency
    var currency: String { get set }
    /// Whether the fiat conversion is on/off
    var isFiatConverted: Bool { get set }
    /// Whether user finished recovery phrase backup test
    var isRecoveryPhraseTestCompleted: Bool { get set }
    /// Whether the user has been autoshielded in the running session
    var isSessionAutoshielded: Bool { get set }
}

/// Live implementation of the `UserPreferences` using User Defaults
/// according to https://developer.apple.com/documentation/foundation/userdefaults
/// the UserDefaults class is thread-safe.
struct UserPreferencesStorage: UserPreferences {
    enum Constants: String, CaseIterable {
        case zcashActiveAppSessionFrom
        case zcashCurrency
        case zcashFiatConverted
        case zcashRecoveryPhraseTestCompleted
        case zcashSessionAutoshielded
    }

    static let `default` = UserPreferencesStorage(
        appSessionFrom: Date().timeIntervalSince1970,
        convertedCurrency: "USD",
        fiatConvertion: true,
        recoveryPhraseTestCompleted: false,
        sessionAutoshielded: true,
        userDefaults: UserDefaults.standard
    )
    
    /// Default values for all preferences in case there is no value stored (counterparts to `Constants`)
    private let appSessionFrom: TimeInterval
    private let convertedCurrency: String
    private let fiatConvertion: Bool
    private let recoveryPhraseTestCompleted: Bool
    private let sessionAutoshielded: Bool
    
    private let userDefaults: UserDefaults
    
    init(
        appSessionFrom: TimeInterval,
        convertedCurrency: String,
        fiatConvertion: Bool,
        recoveryPhraseTestCompleted: Bool,
        sessionAutoshielded: Bool,
        userDefaults: UserDefaults
    ) {
        self.appSessionFrom = appSessionFrom
        self.convertedCurrency = convertedCurrency
        self.fiatConvertion = fiatConvertion
        self.recoveryPhraseTestCompleted = recoveryPhraseTestCompleted
        self.sessionAutoshielded = sessionAutoshielded
        self.userDefaults = userDefaults
    }
    
    /// From when the app is on and uninterrupted
    var activeAppSessionFrom: TimeInterval {
        get { getValue(forKey: Constants.zcashActiveAppSessionFrom.rawValue, default: appSessionFrom) }
        set { setValue(newValue, forKey: Constants.zcashActiveAppSessionFrom.rawValue) }
    }

    /// What is the set up currency
    var currency: String {
        get { getValue(forKey: Constants.zcashCurrency.rawValue, default: convertedCurrency) }
        set { setValue(newValue, forKey: Constants.zcashCurrency.rawValue) }
    }

    /// Whether the fiat conversion is on/off
    var isFiatConverted: Bool {
        get { getValue(forKey: Constants.zcashFiatConverted.rawValue, default: fiatConvertion) }
        set { setValue(newValue, forKey: Constants.zcashFiatConverted.rawValue) }
    }

    /// Whether user finished recovery phrase backup test
    var isRecoveryPhraseTestCompleted: Bool {
        get { getValue(forKey: Constants.zcashRecoveryPhraseTestCompleted.rawValue, default: recoveryPhraseTestCompleted) }
        set { setValue(newValue, forKey: Constants.zcashRecoveryPhraseTestCompleted.rawValue) }
    }

    /// Whether the user has been autoshielded in the running session
    var isSessionAutoshielded: Bool {
        get { getValue(forKey: Constants.zcashSessionAutoshielded.rawValue, default: sessionAutoshielded) }
        set { setValue(newValue, forKey: Constants.zcashSessionAutoshielded.rawValue) }
    }

    /// Use carefully: Deletes all user preferences from the User Defaults
    func removeAll() {
        Constants.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
    }
}

private extension UserPreferencesStorage {
    func getValue<Value>(forKey: String, default defaultIfNil: Value) -> Value {
        userDefaults.object(forKey: forKey) as? Value ?? defaultIfNil
    }

    func setValue<Value>(_ value: Value, forKey: String) {
        userDefaults.set(value, forKey: forKey)
        userDefaults.synchronize()
    }
}
