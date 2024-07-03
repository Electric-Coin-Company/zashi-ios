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
            VStack {
                Text("Hello!")
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .padding(.horizontal, 35)
                    .padding(.top, 50)
                
                Asset.Assets.deeplinkWarning.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 109, height: 106)
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.vertical, 50)
                
                Text("Looks like you used a third-party app to scan for payment.")
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                
                Text("For better safety and security, rescan the QR code with Zashi.")
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 16))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 45)
                
                Spacer()
                
                Button("Rescan in Zashi".uppercased()) {
                    store.send(.gotItTapped)
                }
                .zcashStyle()
                .padding(.horizontal, 50)
                .padding(.vertical, 50)
            }
            .padding(.horizontal, 30)
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
