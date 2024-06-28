//
//  RequestPaymentView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-24-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Utils

public struct RequestPaymentView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<RequestPayment>
    
    @FocusState private var isAmountFocused
    @FocusState private var isMessageFocused

    public init(store: StoreOf<RequestPayment>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.Send.toSummary)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        Text(store.toAddress)
                            .font(.custom(FontFamily.Inter.regular.name, size: 13))
                            .foregroundColor(Asset.Colors.shade47.color)
                            .lineSpacing(3)
                    }
                    Spacer()
                }
                .padding(.vertical, 15)

                VStack(alignment: .leading) {
                    ZashiTextField(
                        text: $store.zecAmountText,
                        placeholder: "ZEC Amount",
                        title: L10n.Send.amountSummary
                    )
                    .focused($isAmountFocused)
                    .keyboardType(.decimalPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button(L10n.General.done.uppercased()) {
                                isMessageFocused = false
                                isAmountFocused = false
                            }
                            .foregroundColor(Asset.Colors.primary.color)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        }
                    }
                    
                    if store.isInvalidAmount {
                        Text(L10n.Send.Error.invalidAmount)
                            .foregroundColor(Asset.Colors.error.color)
                            .font(.custom(FontFamily.Inter.regular.name, size: 12))
                    }
                }
                .padding(.bottom, 15)

                if store.isMemoPossible {
                    MessageEditor(
                        store: store.scope(
                            state: \.memoState,
                            action: \.memo
                        ),
                        placeholder: "What's this for?"
                    )
                    .frame(height: 175)
                    .focused($isMessageFocused)
                }
                
                Spacer()
                
                Button("SHARE QR CODE") {
                    store.send(.shareQRCodeTapped)
                }
                .zcashStyle()
                .padding(.horizontal, 30)
                .padding(.vertical, 30)
                .disabled(!store.isValidInput)
                
                shareView()
            }
            .padding(.vertical, 1)
            .padding(.horizontal, 35)
            .zashiBack()
            .zashiTitle {
                Text("Zashi Me".uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
    
    @ViewBuilder func shareView() -> some View {
        if let encryptedOutput = store.encryptedOutput,
           let cgImg = QRCodeGenerator.generate(
            from: encryptedOutput,
            color: colorScheme == .dark ? Asset.Colors.shade85.systemColor : Asset.Colors.primary.systemColor
           ) {
            UIShareDialogView(activityItems: [UIImage(cgImage: cgImg)]) {
                store.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    RequestPaymentView(store: RequestPayment.initial)
}

// MARK: - Store

extension RequestPayment {
    public static var initial = StoreOf<RequestPayment>(
        initialState: .initial
    ) {
        RequestPayment()
    }
}

// MARK: - Placeholders

extension RequestPayment.State {
    public static let initial = RequestPayment.State(memoState: .initial, toAddress: "")
}
