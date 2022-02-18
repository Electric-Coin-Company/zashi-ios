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
    static let validationWordTypeIdentifier = "public.text"

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
    /// Makes a View accept drop types Self.validationWordTypeIdentifier when it is of kind .empty
    func whenIsDroppable(_ isDroppable: Bool, dropDelegate: DropDelegate) -> some View {
        self.modifier(MakeDroppableModifier(isDroppable: isDroppable, drop: dropDelegate))
    }
}

struct MakeDroppableModifier: ViewModifier {
    var isDroppable: Bool
    var drop: DropDelegate
    
    func body(content: Content) -> some View {
        if isDroppable {
            content.onDrop(of: [PhraseChip.validationWordTypeIdentifier], delegate: drop)
        } else {
            content
        }
    }
}
