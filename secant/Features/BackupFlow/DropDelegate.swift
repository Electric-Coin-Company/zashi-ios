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

/// Drop delegate that accepts items conforming to `PhraseChip.completionTypeIdentifier`
struct WordChipDropDelegate: DropDelegate {
    var dropAction: ((PhraseChip.Kind) -> Void)?

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [PhraseChip.completionTypeIdentifier])
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [PhraseChip.completionTypeIdentifier]).first {
            item.loadItem(forTypeIdentifier: PhraseChip.completionTypeIdentifier, options: nil) { loadedItem, _ in
                DispatchQueue.main.async {
                    if let word = loadedItem as? NSString {
                        dropAction?(.unassigned(word: word as String))
                    }
                }
            }
            return true
        }
        return false
    }
}

extension RecoveryPhraseValidationStep {
    func dropDelegate(
        for viewStore: RecoveryPhraseValidationViewStore,
        group: Int
    ) -> DropDelegate {
        switch self {
        case .initial:
            return WordChipDropDelegate { chipKind in
                switch chipKind {
                case .unassigned:
                    viewStore.send(.drag(wordChip: chipKind, intoGroup: group))
                default:
                    break
                }
            }
        case .incomplete(_, _, completion: let completion, _):
            guard completion.first(where: { $0.groupIndex == group }) == nil else { return NullDelegate() }

            return WordChipDropDelegate { chipKind in
                viewStore.send(.drag(wordChip: chipKind, intoGroup: group))
            }
        case .complete, .valid, .invalid:
            return NullDelegate()
        }
    }
}

extension RecoveryPhraseValidationStep {
    func groupCompleted(index: Int) -> Bool {
        switch self {
        case .valid, .invalid, .complete:
            return true
        case .initial:
            return false
        case .incomplete(_, _, let completion, _):
            return completion.first(where: { $0.groupIndex == index }) != nil
        }
    }
}
