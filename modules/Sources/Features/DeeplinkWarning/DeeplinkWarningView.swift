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
            //ScrollView {
                VStack {
                    Text("Deeplink warning")
                        .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                        .padding(.horizontal, 35)
                        .padding(.vertical, 50)

                    Text("Looks like you used a third-party app to scan for payment. For better safety and security, rescan the QR code with Zashi."
                    )
                    .font(.custom(FontFamily.Archivo.regular.name, size: 16))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 30)

                    Spacer()
                    
                    Button("I got it".uppercased()) {
                        store.send(.gotItTapped)
                    }
                    .zcashStyle()
                    .padding(.horizontal, 50)
                    .padding(.vertical, 50)
                }
                .padding(.horizontal, 30)
//            }
//            .padding(.vertical, 1)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
    }
}

// MARK: - Previews

#Preview {
    DeeplinkWarningView(store: DeeplinkWarning.initial)
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
