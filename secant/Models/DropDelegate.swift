//
//  DropDelegate.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 11/16/21.
//

import Foundation
import SwiftUI
import OrderedCollections
import ComposableArchitecture

/// Drop delegate that accepts items conforming to `PhraseChip.validationWordTypeIdentifier`
struct WordChipDropDelegate: DropDelegate {
    var dropAction: ((PhraseChip.Kind) -> Void)?

    func validateDrop(info: DropInfo) -> Bool {
        return  info.hasItemsConforming(to: [PhraseChip.validationWordTypeIdentifier])
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [PhraseChip.validationWordTypeIdentifier]).first {
            item.loadItem(forTypeIdentifier: PhraseChip.validationWordTypeIdentifier, options: nil) { text, _ in
                DispatchQueue.main.async {
                    if let data = text as? Data {
                        //  Extract string from data

                        let word = String(decoding: data, as: UTF8.self)
                        dropAction?(.unassigned(word: word as String))
                    }
                }
            }
            return true
        }
        return false
    }
}

extension RecoveryPhraseValidationFlowReducer.State {
    func groupCompleted(index: Int) -> Bool {
        validationWords.first(where: { $0.groupIndex == index }) != nil
    }
}
