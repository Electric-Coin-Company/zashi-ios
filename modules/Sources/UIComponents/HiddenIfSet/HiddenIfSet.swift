//
//  HiddenIfSet.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-23-2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

import Generated

struct HiddenIfSetModifier: ViewModifier {
    @Dependency(\.hideBalances) var hideBalances
    @State var isHidden = false
    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isHidden {
                Text(L10n.General.hideBalancesMostStandalone)
            } else {
                content
            }
        }
        .onAppear {
            cancellable = hideBalances.value().sink { val in
                isHidden = val
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}

extension Text {
    public func hiddenIfSet() -> some View {
        modifier(HiddenIfSetModifier())
    }
}
