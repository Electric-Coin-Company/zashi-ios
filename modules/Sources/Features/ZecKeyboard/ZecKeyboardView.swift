//
//  ZecKeyboardView.swift
//  modules
//
//  Created by Lukáš Korba on 20.09.2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils

public struct ZecKeyboardView: View {
    @Perception.Bindable var store: StoreOf<ZecKeyboard>
    
    public init(store: StoreOf<ZecKeyboard>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                if !store.isValidInput {
                    HStack(spacing: 0) {
                        Asset.Assets.infoOutline.image
                            .zImage(size: 20, style: Design.Utility.WarningYellow._500)
                            .padding(.trailing, 12)
                        
                        Text("This transaction amount is invalid.")
                            .zFont(.medium, size: 14, style: Design.Utility.WarningYellow._700)
                            .padding(.top, 3)
                    }
                    .padding(.horizontal, 10)
                    .screenHorizontalPadding()
                    .padding(.bottom, 4)
                }

                HStack(spacing: 0) {
                    if store.isInputInZec {
                        Text(store.humanReadableMainInput)
                        + Text(" ZEC")
                            .foregroundColor(Design.Text.quaternary.color)
                    } else {
                        if store.isCurrencySymbolPrefix {
                            Text(store.localeCurrencySymbol)
                                .foregroundColor(Design.Text.quaternary.color)
                            + Text(store.humanReadableMainInput)
                        } else {
                            Text(store.humanReadableMainInput)
                            + Text(" \(store.localeCurrencySymbol)")
                                .foregroundColor(Design.Text.quaternary.color)
                        }
                    }
                }
                .zFont(.semiBold, size: 56, style: Design.Text.primary)
                .frame(height: 68)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .screenHorizontalPadding()
                .padding(.vertical, 1)

                if store.currencyConversion != nil {
                    HStack(spacing: 0) {
                        Group {
                            if store.isInputInZec {
                                if store.isCurrencySymbolPrefix {
                                    Text(store.localeCurrencySymbol)
                                        .foregroundColor(Design.Text.quaternary.color)
                                    + Text(store.humanReadableConvertedInput)
                                } else {
                                    Text(store.humanReadableConvertedInput)
                                    + Text(" \(store.localeCurrencySymbol)")
                                        .foregroundColor(Design.Text.quaternary.color)
                                }
                            } else {
                                Text(store.humanReadableConvertedInput)
                                + Text(" ZEC")
                                    .foregroundColor(Design.Text.quaternary.color)
                            }
                        }
                        .zFont(.medium, size: 18, style: Design.Text.primary)
                        .padding(.trailing, 9)

                        Button {
                            store.send(.swapCurrenciesTapped)
                        } label: {
                            Asset.Assets.Icons.switchHorizontal.image
                                .zImage(size: 24, style: Design.Btns.Tertiary.fg)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.Btns.Tertiary.bg.color)
                                }
                                .rotationEffect(Angle(degrees: 90))
                        }
                    }
                    .minimumScaleFactor(0.6)
                    .screenHorizontalPadding()
                }

                Spacer()

                if store.keys.count == 12 {
                    VStack(spacing: 0) {
                        ForEach(0..<4) { column in
                            HStack {
                                Spacer()
                                
                                ForEach(0..<3) { row in
                                    VStack {
                                        WithPerceptionTracking {
                                            Button {
                                                store.send(.keyTapped(column * 3 + row))
                                            } label: {
                                                if store.keys[column * 3 + row] == "x" {
                                                    Asset.Assets.Icons.delete.image
                                                        .zImage(size: 40, style: Design.Text.primary)
                                                        .onLongPressGesture(minimumDuration: 0.7) {
                                                            store.send(.longKeyTapped(column * 3 + row))
                                                        }
                                                } else {
                                                    Text(store.keys[column * 3 + row])
                                                        .zFont(.semiBold, size: 32, style: Design.Text.primary)
                                                        .frame(width: 40, height: 40)
                                                }
                                            }
                                            .padding(10)
                                        }
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                    .padding(.bottom, 24)
                }

                ZashiButton("Next") {
                    store.send(.nextTapped)
                }
                .disabled(store.isNextButtonDisabled)
                .padding(.bottom, 24)
                .screenHorizontalPadding()
            }
            .onAppear { store.send(.onAppear) }
        }
        .applyScreenBackground()
        .zashiBack()
        .screenTitle("Request")
    }
}

#Preview {
    NavigationView {
        ZecKeyboardView(store: ZecKeyboard.placeholder)
    }
}

// MARK: - Placeholders

extension ZecKeyboard.State {
    public static let initial = ZecKeyboard.State()
}

extension ZecKeyboard {
    public static let placeholder = StoreOf<ZecKeyboard>(
        initialState: .initial
    ) {
        ZecKeyboard()
    }
}