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

/// There's no way to pass a nullable action to a droppable target. So, the Null Object Pattern comes to the rescue
struct NullDelegate: DropDelegate {
    func validateDrop(info: DropInfo) -> Bool {
        return false
    }

    func performDrop(info: DropInfo) -> Bool {
        false
    }
}

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

extension RecoveryPhraseValidationState {
    func dropDelegate(
        for viewStore: RecoveryPhraseValidationViewStore,
        group: Int
    ) -> DropDelegate {
        switch self.step {
        case .initial:
            return WordChipDropDelegate { chipKind in
                switch chipKind {
                case .unassigned:
                    viewStore.send(.drag(wordChip: chipKind, intoGroup: group))
                default:
                    break
                }
            }
        case .incomplete:
            guard validationWords.first(where: { $0.groupIndex == group }) == nil else { return NullDelegate() }

            return WordChipDropDelegate { chipKind in
                viewStore.send(.drag(wordChip: chipKind, intoGroup: group))
            }
        case .complete:
            return NullDelegate()
        }
    }
}

extension RecoveryPhraseValidationState {
    func groupCompleted(index: Int) -> Bool {
        validationWords.first(where: { $0.groupIndex == index }) != nil
    }
}
