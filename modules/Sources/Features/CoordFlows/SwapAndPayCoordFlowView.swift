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
                    case let .addressBook(store):
                        AddressBookView(store: store)
                    case let .addressBookContact(store):
                        AddressBookContactView(store: store)
                    case let .confirmWithKeystone(store):
                        SignWithKeystoneView(store: store, tokenName: tokenName)
                    case let .preSendingFailure(store):
                        PreSendingFailureView(store: store, tokenName: tokenName)
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
                    case let .swapAndPayForm(store):
                        SwapAndPayForm(store: store, tokenName: tokenName)
                    case let .swapAndPayOptInForced(store):
                        SwapAndPayOptInForcedView(store: store)
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
                            Asset.Assets.infoCircle.image
                                .zImage(size: 24, style: Design.Text.primary)
                                .padding(8)
                        }
                )
                .zashiSheet(isPresented: $store.isHelpSheetPresented) {
                    helpContent()
                        .screenHorizontalPadding()
                        .applyScreenBackground()
                }
                .onAppear { store.send(.onAppear) }
            }
            .applyScreenBackground()
            .zashiBack {
                store.send(.backButtonTapped)
            }
            .zashiTitle {
                HStack(spacing: 0) {
                    Text(
                        store.isSwapExperience
                        ? L10n.SwapAndPay.Help.swapWith
                        : L10n.SwapAndPay.Help.payWith
                    )
                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                    .padding(.trailing, 10)
                    
                    Asset.Assets.Partners.nearLogo.image
                        .zImage(width: 65, height: 16, style: Design.Text.primary)
                }
                .padding(.trailing, 20)
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder func helpContent() -> some View {
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
        VStack(alignment: .leading, spacing: 0) {
            Asset.Assets.Icons.arrowDown.image
                .zImage(size: 20, style: Design.Text.primary)
                .padding(10)
                .background {
                    Circle()
                        .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                }
                .padding(.top, 24)

            HStack(spacing: 10) {
                Text(
                    store.isSwapExperience
                    ? L10n.SwapAndPay.Help.swapWith
                    : L10n.SwapAndPay.Help.payWith
                )
                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                
                Asset.Assets.Partners.nearLogo.image
                    .zImage(width: 98, height: 24, style: Design.Text.primary)
            }
            .padding(.vertical, 12)

            if store.isSwapExperience {
                infoContent(index: 0, text: L10n.SwapAndPay.Help.swapDesc, desc2: L10n.SwapAndPay.Help.swapDesc2)
                    .padding(.bottom, 32)
            } else {
                infoContent(index: 1, text: L10n.SwapAndPay.Help.payDesc1, desc2: L10n.SwapAndPay.Help.payDesc2)
                    .padding(.bottom, 32)
            }
            
            ZashiButton(L10n.General.ok.uppercased()) {
                store.send(.helpSheetRequested)
            }
            .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder private func infoContent(index: Int, text: String, desc2: String? = nil) -> some View {
//        HStack(alignment: .top, spacing: 16) {
//            if index == 0 {
//                Asset.Assets.Icons.arrowDown.image
//                    .zImage(size: 20, style: Design.Text.primary)
//                    .padding(10)
//                    .background {
//                        Circle()
//                            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
//                    }
//            } else {
//                Asset.Assets.Icons.coinsSwap.image
//                    .zImage(size: 20, style: Design.Text.primary)
//                    .padding(10)
//                    .background {
//                        Circle()
//                            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
//                    }
//            }

            VStack(alignment: .leading, spacing: 6) {
                Text(text)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1.5)
                
                if let desc2 {
                    Text(desc2)
                        .zFont(size: 14, style: Design.Text.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)
                        .padding(.top, 16)
                }
            }
            
//            Spacer()
//        }
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
