//
//  MockServices.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//
// TODO: Move this to different Target when real functionality is developed.
import Foundation

class MockServices: Services {
    var networkProvider: ZcashNetworkProvider = MockNetworkProvider()
        
    var seedHandler: MnemonicSeedPhraseProvider = .mock
    
    var keyStorage: KeyStoring = MockKeyStoring()
}

class MockNetworkProvider: ZcashNetworkProvider {
    func currentNetwork() -> ZcashNetwork {
        ZcashMainnet()
    }
}

class KeysPresentStub: KeyStoring {
    init(returnBlock: @escaping () throws -> Bool) {
        self.returnBlock = returnBlock
    }
    var returnBlock: () throws -> Bool
    var called = false
    func areKeysPresent() throws -> Bool {
        called = true
        return try returnBlock()
    }
    
    var birthday: BlockHeight?
    var phrase: String?
    func importBirthday(_ height: BlockHeight) throws {
        guard birthday == nil else {
            throw KeyStoringError.alreadyImported
        }
        birthday = height
    }
    
    func exportBirthday() throws -> BlockHeight {
        guard let birthday = birthday else {
            throw KeyStoringError.uninitializedWallet
        }
        return birthday
    }
    
    func importPhrase(bip39 phrase: String) throws {
        guard self.phrase == nil else {
            throw KeyStoringError.alreadyImported
        }
        self.phrase = phrase
    }
    
    func exportPhrase() throws -> String {
        guard let phrase = self.phrase else {
            throw KeyStoringError.uninitializedWallet
        }
        return phrase
    }
    
    var keysPresent: Bool {
        return self.phrase != nil && self.birthday != nil
    }
    
    func nukePhrase() {
        self.phrase = nil
    }
    
    func nukeBirthday() {
        self.birthday = nil
    }
    
    func nukeWallet() {
        nukePhrase()
        nukeBirthday()
    }
}
class MockKeyStoring: KeyStoring {
    var birthday: BlockHeight?
    var phrase: String?

    var keysPresent: Bool {
        return self.phrase != nil && self.birthday != nil
    }
    
    func areKeysPresent() throws -> Bool {
        false
    }

    func importBirthday(_ height: BlockHeight) throws {
        guard birthday == nil else {
            throw KeyStoringError.alreadyImported
        }

        birthday = height
    }

    func exportBirthday() throws -> BlockHeight {
        guard let birthday = birthday else {
            throw KeyStoringError.uninitializedWallet
        }

        return birthday
    }

    func importPhrase(bip39 phrase: String) throws {
        guard self.phrase == nil else {
            throw KeyStoringError.alreadyImported
        }

        self.phrase = phrase
    }

    func exportPhrase() throws -> String {
        guard let phrase = self.phrase else {
            throw KeyStoringError.uninitializedWallet
        }
        
        return phrase
    }

    func nukePhrase() {
        self.phrase = nil
    }

    func nukeBirthday() {
        self.birthday = nil
    }

    func nukeWallet() {
        nukePhrase()
        nukeBirthday()
    }
}
