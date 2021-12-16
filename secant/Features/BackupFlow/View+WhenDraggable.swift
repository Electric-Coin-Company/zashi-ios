//
//  PhraseChip+WhenDraggable.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 11/4/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture
extension PhraseChip {
    static let completionTypeIdentifier = "public.text"

    /// Makes a PhraseChip draggable when it is of kind .unassigned
    @ViewBuilder func makeDraggable() -> some View {
        switch self.kind {
        case .unassigned(let word):
            self.onDrag {
                NSItemProvider(object: word as NSString)
            }
        default:
            self
        }
    }
}

extension View {
    func onDrop(
        for step: RecoveryPhraseValidationState.RecoveryPhraseValidationStep,
        group: Int,
        viewStore: RecoveryPhraseValidationViewStore
    ) -> some View {
        self.onDrop(
            of: [PhraseChip.completionTypeIdentifier],
            delegate: step.dropDelegate(for: viewStore, group: group)
        )
    }
}

extension View {
    /// Makes a View accept drop types Self.completionTypeIdentifier when it is of kind .empty
    func whenIsDroppable(_ isDroppable: Bool, dropDelegate: DropDelegate) -> some View {
        self.modifier(MakeDroppableModifier(isDroppable: isDroppable, drop: dropDelegate))
    }
}

struct MakeDroppableModifier: ViewModifier {
    var isDroppable: Bool
    var drop: DropDelegate
    func body(content: Content) -> some View {
        if isDroppable {
            content.onDrop(of: [PhraseChip.completionTypeIdentifier], delegate: drop)
        } else {
            content
        }
    }
}
