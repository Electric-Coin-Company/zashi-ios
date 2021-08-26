//
//  KeyStoring.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation


protocol KeyStoring {
    func importBirthday(_ height: BlockHeight) throws
    func exportBirthday() throws -> BlockHeight
    func importPhrase(bip39 phrase: String) throws
    func exportPhrase() throws -> String
    var keysPresent: Bool { get }
    /**
     Use carefully: Deletes the seed phrase from the keychain
     */
    func nukePhrase()

    /**
     Use carefully: deletes the wallet birthday from the keychain
     */
    func nukeBirthday()

    /**
    There's no fate but what we make for ourselves - Sarah Connor
    */
    func nukeWallet()
}

enum KeyStoringError : Error {
    case alreadyImported
    case uninitializedWallet
}
