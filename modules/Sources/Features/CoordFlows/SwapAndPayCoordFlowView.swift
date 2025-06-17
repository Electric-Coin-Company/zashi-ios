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
            .padding(.horizontal, 4)
            .applyScreenBackground()
            .zashiBack()
            .zashiTitle {
                HStack(spacing: 0) {
                    operationChip(index: 0, text: "Swap", colorScheme)
                    operationChip(index: 1, text: "Pay", colorScheme)
                }
                .padding(.horizontal, 2)
                .frame(minWidth: 200)
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
                .frame(minWidth: 100)
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
                .frame(minWidth: 100)
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
            Text(L10n.RestoreWallet.Help.title)
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.top, 24)
                .padding(.bottom, 12)
            
            infoContent(text: L10n.RestoreWallet.Help.phrase)
                .padding(.bottom, 12)
            
            infoContent(text: L10n.RestoreWallet.Help.birthday)
                .padding(.bottom, 32)
            
            ZashiButton(L10n.RestoreInfo.gotIt) {
                store.send(.helpSheetRequested)
            }
            .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder private func infoContent(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Asset.Assets.infoCircle.image
                .zImage(size: 20, style: Design.Text.primary)
            
            if let attrText = try? AttributedString(
                markdown: text,
                including: \.zashiApp
            ) {
                ZashiText(withAttributedString: attrText, colorScheme: colorScheme)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
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
