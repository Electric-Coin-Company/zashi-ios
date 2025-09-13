//
//  SwapToZecSummaryView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-09-12.
//

import SwiftUI
import ComposableArchitecture
import Generated
import SwapAndPay

import UIComponents

public struct SwapToZecSummaryView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false

    @Perception.Bindable var store: StoreOf<SwapAndPay>
    let tokenName: String
    
    public init(store: StoreOf<SwapAndPay>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack() {
                Text("Confirm")
            }
            .navigationBarItems(
                trailing:
                    HStack(spacing: 4) {
                        Button {
                            $isSensitiveContentHidden.withLock { $0.toggle() }
                        } label: {
                            let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
                            image
                                .zImage(size: 24, color: Asset.Colors.primary.color)
                                .padding(8)
                        }
                        
                        Button {
                            store.send(.helpSheetRequested(3))
                        } label: {
                            Asset.Assets.infoCircle.image
                                .zImage(size: 24, style: Design.Text.primary)
                                .padding(8)
                        }
                    }
            )
            .zashiBack()
            .screenTitle(L10n.SwapAndPay.swap.uppercased())
            .screenHorizontalPadding()
            .applyScreenBackground()
        }
    }
}
