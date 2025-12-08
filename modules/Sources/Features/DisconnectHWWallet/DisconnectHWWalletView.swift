//
//  DisconnectHWWalletView.swift
//  Zashi
//
//  Created by Lukáš Korba on 12-08-2025
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct DisconnectHWWalletView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<DisconnectHWWallet>
    
    public init(store: StoreOf<DisconnectHWWallet>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.DisconnectHWWallet.title)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 40)

                Text(L10n.DisconnectHWWallet.desc1)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.top, 12)
                    .lineSpacing(2)

                Text(L10n.DisconnectHWWallet.desc2)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .lineSpacing(2)

                HStack(spacing: 0) {
                    Asset.Assets.Partners.keystoneSeekLogo.image
                        .resizable()
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.brandFg.color(colorScheme))
                        }
                        .padding(.trailing, 8)
                        .overlay {
                            Circle()
                                .fill(Design.Utility.SuccessGreen._500.color(colorScheme))
                                .frame(width: 14, height: 14)
                                .background {
                                    Circle()
                                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                                        .frame(width: 20, height: 20)
                                }
                                .offset(x: 17, y: 17)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.DisconnectHWWallet.kyestonePro)
                            .zFont(.semiBold, size: 16, style: Design.Text.primary)
                        
                        Text(L10n.DisconnectHWWallet.currentlyConnected)
                            .zFont(size: 14, style: Design.Text.primary)
                    }
                    .padding(.leading, Design.Spacing._xl)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Design.Spacing._2xl)
                .padding(.vertical, Design.Spacing._xl)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._2xl)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                }

                Spacer()

                if store.isProcessing {
                    ZashiButton(
                        L10n.DisconnectHWWallet.disconnect,
                        type: .destructive1,
                        accessoryView: ProgressView()
                    ) { }
                    .disabled(true)
                    .padding(.bottom, 24)
                } else {
                    ZashiButton(
                        L10n.DisconnectHWWallet.disconnect,
                        type: .destructive1
                    ) {
                        store.send(.disconnectRequested)
                    }
                    .disabled(store.isProcessing)
                    .padding(.bottom, 24)
                }
            }
            .zashiBack(store.isProcessing)
            .zashiSheet(isPresented: $store.isAreYouSureSheetPresented) {
                areYouSureSheet(colorScheme: colorScheme)
                    .screenHorizontalPadding()
                    .applyScreenBackground()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.DisconnectHWWallet.disconnect.uppercased())
    }
    
    @ViewBuilder func areYouSureSheet(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 0) {
            Asset.Assets.Icons.arrowUp.image
                .zImage(size: 20, style: Design.Utility.ErrorRed._500)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._full)
                        .fill(Design.Utility.ErrorRed._100.color(colorScheme))
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 48)
                .padding(.bottom, 20)

            Text(L10n.KeystoneTransactionReject.title)
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.bottom, 8)

            Text(L10n.DisconnectHWWallet.areYouSureDesc)
                .zFont(size: 14, style: Design.Text.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            ZashiButton(
                L10n.DisconnectHWWallet.disconnect,
                type: .destructive2
            ) {
                store.send(.disconnectDevice)
            }
            .padding(.bottom, 8)

            ZashiButton(L10n.General.cancel) {
                store.send(.disconnectCanceled)
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Previews

#Preview {
    DisconnectHWWalletView(store: DisconnectHWWallet.initial)
}

// MARK: - Store

extension DisconnectHWWallet {
    public static var initial = StoreOf<DisconnectHWWallet>(
        initialState: .initial
    ) {
        DisconnectHWWallet()
    }
}

// MARK: - Placeholders

extension DisconnectHWWallet.State {
    public static let initial = DisconnectHWWallet.State()
}
