//
//  DeeplinkWarningView.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-12-2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct DeeplinkWarningView: View {
    @Perception.Bindable var store: StoreOf<DeeplinkWarning>

    public init(store: StoreOf<DeeplinkWarning>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()
                
                Asset.Assets.qrcodeScannerErr.image
                    .resizable()
                    .frame(width: 164, height: 186)
                    .padding(.bottom, 24)
                    .padding(.leading, 12)

                Text("Looks like you used a third-party app to scan for payment.")
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("For better safety and security, rescan the QR code with Zashi.")
                    .zFont(size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.center)
                    .screenHorizontalPadding()
                    .padding(.vertical, 12)

                Spacer()

                ZashiButton("Rescan in Zashi") {
                    store.send(.gotItTapped)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyErredScreenBackground()
        .screenTitle("HELLO!")
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        DeeplinkWarningView(store: DeeplinkWarning.initial)
    }
}

// MARK: - Store

extension DeeplinkWarning {
    public static var initial = StoreOf<DeeplinkWarning>(
        initialState: .initial
    ) {
        DeeplinkWarning()
    }
}

// MARK: - Placeholders

extension DeeplinkWarning.State {
    public static let initial = DeeplinkWarning.State()
}