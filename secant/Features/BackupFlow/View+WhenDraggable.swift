//
//  PhraseChip+WhenDraggable.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 11/4/21.
//

import Foundation
import SwiftUI

extension PhraseChip {
    static let completionTypeIdentifier = "private.secant.chipCompletion"

    /// Makes a PhraseChip draggable when it is of kind .unassigned
    @ViewBuilder func makeDraggable() -> some View {
        switch self.kind {
        case .unassigned(let word):
            self.onDrag {
                NSItemProvider(item: word as NSString, typeIdentifier: PhraseChip.completionTypeIdentifier)
            }
        default:
            self
        }
    }
}

extension View {
    /// Makes a View accept drop types Self.completionTypeIdentifier when it is of kind .empty
    func whenDroppable(_ isDroppable: Bool, dropDelegate: DropDelegate) -> some View {
        self.modifier(MakeDroppableModifier(isDroppable: isDroppable, dropDelegate: dropDelegate))
    }
}

struct MakeDroppableModifier: ViewModifier {
    var isDroppable: Bool
    var dropDelegate: DropDelegate
    func body(content: Content) -> some View {
        if isDroppable {
            content.onDrop(of: [PhraseChip.completionTypeIdentifier], delegate: dropDelegate)
        } else {
            content
        }
    }
}
