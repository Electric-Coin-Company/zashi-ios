//
//  MockServices.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//
// TODO: Move this to diferent Target when real functionality is developed.
import Foundation

// swiftlint:disable line_length
class MockServices: Services {
    var networkProvider: ZcashNetworkProvider = MockNetworkProvider()
        
    var seedHandler: MnemonicSeedPhraseHandling = MockMnemonicPhraseHandling()
    
    var keyStorage: KeyStoring = MockKeyStoring()
}

class MockNetworkProvider: ZcashNetworkProvider {
    func currentNetwork() -> ZcashNetwork {
        ZcashMainnet()
    }
}

class MockMnemonicPhraseHandling: MnemonicSeedPhraseHandling {
    class TestSeed {
        /**
        Test account: "still champion voice habit trend flight survey between bitter process artefact blind carbon truly provide dizzy crush flush breeze blouse charge solid fish spread"
        */
        let seedString = Data(
            base64Encoded: "9VDVOZZZOWWHpZtq1Ebridp3Qeux5C+HwiRR0g7Oi7HgnMs8Gfln83+/Q1NnvClcaSwM4ADFL1uZHxypEWlWXg=="
        )!// swiftlint:disable:this force_unwrapping

        func seed() -> [UInt8] {
            [UInt8](seedString)
        }
    }

    func randomMnemonic() throws -> String {
        "still champion voice habit trend flight survey between bitter process artefact blind carbon truly provide dizzy crush flush breeze blouse charge solid fish spread"
    }

    func randomMnemonicWords() throws -> [String] {
        "still champion voice habit trend flight survey between bitter process artefact blind carbon truly provide dizzy crush flush breeze blouse charge solid fish spread"
        .components(separatedBy: " ")
    }

    func toSeed(mnemonic: String) throws -> [UInt8] {
        TestSeed().seed()
    }

    func asWords(mnemonic: String) throws -> [String] {
        "still champion voice habit trend flight survey between bitter process artefact blind carbon truly provide dizzy crush flush breeze blouse charge solid fish spread"
        .components(separatedBy: " ")
    }

    func isValid(mnemonic: String) throws {}
}

class KeysPresentStub: KeyStoring {
    var returnBlock: () throws -> Bool
    var isAreKeysPresentFunctionCalled = false
    var birthday: BlockHeight?
    var phrase: String?

    var keysPresent: Bool {
        return self.phrase != nil && self.birthday != nil
    }

    init(returnBlock: @escaping () throws -> Bool) {
        self.returnBlock = returnBlock
    }

    func areKeysPresent() throws -> Bool {
        isAreKeysPresentFunctionCalled = true
        return try returnBlock()
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
