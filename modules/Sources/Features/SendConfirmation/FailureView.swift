//
//  FailureView.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-28-2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import Utils
import PartialProposalError
import AddressBook
import TransactionDetails

public struct FailureView: View {
    @Perception.Bindable var store: StoreOf<SendConfirmation>
    let tokenName: String
    
    public init(store: StoreOf<SendConfirmation>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()

                store.failureIlustration
                    .resizable()
                    .frame(width: 148, height: 148)

                Text(store.isShielding ? L10n.Send.failureShielding : L10n.Send.failure)
                    .zFont(.semiBold, size: 28, style: Design.Text.primary)
                    .padding(.top, 16)

                Text(store.isShielding ? L10n.Send.failureShieldingInfo : L10n.Send.failureInfo)
                    .zFont(size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1.5)
                    .screenHorizontalPadding()

                if store.txIdToExpand != nil {
                    ZashiButton(
                        L10n.Send.viewTransaction,
                        type: .tertiary,
                        infinityWidth: false
                    ) {
                        store.send(.viewTransactionTapped)
                    }
                    .padding(.top, 16)
                }

                Spacer()
                
                ZashiButton(L10n.General.close) {
                    store.send(.backFromFailurePressed)
                }
                .padding(.bottom, 8)

                ZashiButton(
                    L10n.Send.report,
                    type: .ghost
                ) {
                    store.send(.reportTapped)
                }
                .padding(.bottom, 24)
                
                if let supportData = store.supportData {
                    UIMailDialogView(
                        supportData: supportData,
                        completion: {
                            store.send(.sendSupportMailFinished)
                        }
                    )
                    // UIMailDialogView only wraps MFMailComposeViewController presentation
                    // so frame is set to 0 to not break SwiftUIs layout
                    .frame(width: 0, height: 0)
                }
                
                shareMessageView()
            }
            .navigationLinkEmpty(
                isActive: store.bindingForStackTransactions(.details),
                destination: {
                    TransactionDetailsView(
                        store: store.transactionDetailsStore(),
                        tokenName: tokenName
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackTransactions(.addressBook),
                        destination: {
                            AddressBookContactView(store: store.addressBookStore())
                        }
                    )
                }
            )
        }
        .navigationBarBackButtonHidden()
        .padding(.vertical, 1)
        .screenHorizontalPadding()
        .applyFailureScreenBackground()
    }
}

extension FailureView {
    @ViewBuilder func shareMessageView() -> some View {
        if let message = store.messageToBeShared {
            UIShareDialogView(activityItems: [message]) {
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

#Preview {
    NavigationView {
        FailureView(
            store: SendConfirmation.initial,
            tokenName: "ZEC"
        )
    }
}
