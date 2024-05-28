//
//  TransactionAddressTextField.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import SwiftUI
import ComposableArchitecture
import Generated
import AVFoundation

extension AnyTransition {
    static func pulse() -> AnyTransition {
        .modifier(active: PulseModifier(), identity: PulseModifier())
    }
}

struct PulseModifier: ViewModifier {
    @State private var scale = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .animation(.easeIn(duration: 0.5).repeatForever(autoreverses: true), value: scale)
            .onAppear {
                scale = 1.35
            }
    }
}

public struct TransactionAddressTextField: View {
    let store: TransactionAddressTextFieldStore

    public init(store: TransactionAddressTextFieldStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                SingleLineTextField(
                    placeholderText: L10n.Field.TransactionAddress.validZcashAddress,
                    title: L10n.Field.TransactionAddress.to,
                    keyboardType: .default,
                    store: store.scope(
                        state: \.textFieldState,
                        action: \.textField
                    ),
                    titleAccessoryView: { },
                    inputPrefixView: { },
                    inputAccessoryView: {
                        if viewStore.doesButtonPulse {
                            qrCode(viewStore)
                            .onAppear { viewStore.send(.onAppear) }
                            .onDisappear { viewStore.send(.onDisappear) }
                            .transition(.pulse())
                        } else {
                            qrCode(viewStore)
                        }
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func qrCode(_ viewStore: TransactionAddressTextFieldViewStore) -> some View {
        Button {
            viewStore.send(.scanQR)
        } label: {
            Image(systemName: "qrcode")
                .resizable()
                .frame(width: 25, height: 25)
                .tint(Asset.Colors.primary.color)
        }
        .padding(.trailing, 10)
    }
}

struct TransactionAddressTextField_Previews: PreviewProvider {
    static var previews: some View {
        TransactionAddressTextField(
            store: TransactionAddressTextFieldStore(
                initialState: .init(
                    textFieldState: .init(
                        validationType: .floatingPoint,
                        text: "".redacted
                    )
                )
            ) {
                TransactionAddressTextFieldReducer()
            }
        )
        .preferredColorScheme(.light)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
