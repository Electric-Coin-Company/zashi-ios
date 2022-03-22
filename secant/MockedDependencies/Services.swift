//
//  Services.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation

protocol Services {
    var networkProvider: ZcashNetworkProvider { get }
    var seedHandler: MnemonicSeedPhraseProvider { get }
    var keyStorage: KeyStoring { get }
}

protocol ZcashNetworkProvider {
    func currentNetwork() -> ZcashNetwork
}
