//
//  SwapAndPayCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import AddressBook
import Scan
import SwapAndPayForm
import SendConfirmation
import TransactionDetails

public struct SwapAndPayCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var moreSheetHeight: CGFloat = .zero
    
    @Perception.Bindable var store: StoreOf<SwapAndPayCoordFlow>
    let tokenName: String

    public init(store: StoreOf<SwapAndPayCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            WithPerceptionTracking {
                NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                    SwapAndPayForm(
                        store:
                            store.scope(
                                state: \.swapAndPayState,
                                action: \.swapAndPay
                            ),
                        tokenName: tokenName
                    )
                    .navigationBarHidden(true)
                } destination: { store in
                    switch store.case {
                    case let .addressBookChainToken(store):
                        AddressBookChainTokenView(store: store)
                    case let .addressBookContact(store):
                        AddressBookContactView(store: store)
                    case let .scan(store):
                        ScanView(store: store)
                    case let .sending(store):
                        SendingView(store: store, tokenName: tokenName)
                    case let .sendResultFailure(store):
                        FailureView(store: store, tokenName: tokenName)
                    case let .sendResultResubmission(store):
                        ResubmissionView(store: store, tokenName: tokenName)
                    case let .sendResultSuccess(store):
                        SuccessView(store: store, tokenName: tokenName)
                    case let .transactionDetails(store):
                        TransactionDetailsView(store: store, tokenName: tokenName)
                    }
                }
                .navigationBarHidden(!store.path.isEmpty)
                .navigationBarItems(
                    trailing:
                        Button {
                            store.send(.helpSheetRequested)
                        } label: {
                            Asset.Assets.Icons.help.image
                                .zImage(size: 24, style: Design.Text.primary)
                                .padding(8)
                        }
                )
                .zashiSheet(isPresented: $store.isHelpSheetPresented) {
                    moreContent()
                        .screenHorizontalPadding()
                        .applyScreenBackground()
                }
            }
            .applyScreenBackground()
            .zashiBack {
                store.send(.backButtonTapped)
            }
            .zashiTitle {
                HStack(spacing: 0) {
                    operationChip(index: 0, text: "Swap", colorScheme)
                    operationChip(index: 1, text: "Pay", colorScheme)
                }
                .padding(.horizontal, 2)
                .frame(minWidth: 180)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._lg)
                        .fill(Design.Switcher.surfacePrimary.color(colorScheme))
                }
            }
        }
    }
    
    @ViewBuilder private func operationChip(index: Int, text: String, _ colorScheme: ColorScheme) -> some View {
        if store.selectedOperationChip == index {
            Text(text)
                .zFont(.medium, size: 16, style: Design.Switcher.selectedText)
                .frame(minWidth: 90)
                .fixedSize()
                .frame(height: 36)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._lg)
                        .fill(Design.Switcher.selectedBg.color(colorScheme))
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._lg)
                                .stroke(Design.Switcher.selectedStroke.color(colorScheme))
                        }
                }
                .onTapGesture {
                    store.send(.operationChipTapped(index))
                }
        } else {
            Text(text)
                .zFont(.medium, size: 16, style: Design.Switcher.defaultText)
                .frame(minWidth: 90)
                .fixedSize()
                .frame(height: 36)
                .onTapGesture {
                    store.send(.operationChipTapped(index))
                }
        }
    }
    
    @ViewBuilder func moreContent() -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.4, *) {
                helpSheetContent()
                    .presentationDetents([.height(moreSheetHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Design.Radius._4xl)
            } else if #available(iOS 16.0, *) {
                helpSheetContent()
                    .presentationDetents([.height(moreSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                helpSheetContent()
            }
        }
    }
    
    @ViewBuilder private func helpSheetContent() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Text(
                    store.selectedOperationChip == 0
                    ? L10n.SwapAndPay.Help.swapWith
                    : L10n.SwapAndPay.Help.payWith
                )
                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                
                Asset.Assets.Partners.nearLogo.image
                    .zImage(width: 98, height: 24, style: Design.Text.primary)
            }
            .padding(.top, 12)
            .padding(.vertical, 24)

            if store.selectedOperationChip == 0 {
                infoContent(text: L10n.SwapAndPay.Help.swapDesc)
                    .padding(.bottom, 32)
            } else {
                infoContent(text: L10n.SwapAndPay.Help.payDesc)
                    .padding(.bottom, 32)
            }
            
            ZashiButton(L10n.General.ok.uppercased()) {
                store.send(.helpSheetRequested)
            }
            .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder private func infoContent(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if store.selectedOperationChip == 0 {
                Asset.Assets.Icons.arrowDown.image
                    .zImage(size: 20, style: Design.Text.primary)
                    .padding(10)
                    .background {
                        Circle()
                            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                    }
            } else {
                Asset.Assets.Icons.coinsSwap.image
                    .zImage(size: 20, style: Design.Text.primary)
                    .padding(10)
                    .background {
                        Circle()
                            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                    }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(
                    store.selectedOperationChip == 0
                    ? L10n.SwapAndPay.Help.swapWithNear
                    : L10n.SwapAndPay.Help.payWithNear
                )
                .zFont(.semiBold, size: 14, style: Design.Text.primary)

                Text(text)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1.5)
            }
        }
    }
}

#Preview {
    NavigationView {
        SwapAndPayCoordFlowView(store: SwapAndPayCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension SwapAndPayCoordFlow.State {
    public static let initial = SwapAndPayCoordFlow.State()
}

extension SwapAndPayCoordFlow {
    public static let placeholder = StoreOf<SwapAndPayCoordFlow>(
        initialState: .initial
    ) {
        SwapAndPayCoordFlow()
    }
}
