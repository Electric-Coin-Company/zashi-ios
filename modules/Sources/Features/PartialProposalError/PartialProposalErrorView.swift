//
//  PartialProposalErrorView.swift
//
//
//  Created by Lukáš Korba on 11.03.2024.
//

import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents

public struct PartialProposalErrorView: View {
    @Perception.Bindable var store: StoreOf<PartialProposalError>
    
    public init(store: StoreOf<PartialProposalError>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            WithPerceptionTracking {
                VStack(alignment: .center) {
                    ZashiErrorIcon()

                    Group {
                        Text(L10n.ProposalPartial.message1)
                        Text(L10n.ProposalPartial.message2)
                    }
                    .font(.custom(FontFamily.Inter.medium.name, size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                    Text(L10n.ProposalPartial.transactionIds.uppercased())
                        .font(.custom(FontFamily.Inter.bold.name, size: 14))
                        .padding(.top, 30)
                        .padding(.bottom, 3)

                    ForEach(store.txIds, id: \.self) { txId in
                        Text(txId)
                            .font(.custom(FontFamily.Inter.regular.name, size: 13))
                            .padding(.bottom, 3)
                    }

                    Button(L10n.ProposalPartial.contactSupport.uppercased()) {
                        store.send(.sendSupportMail)
                    }
                    .zcashStyle()
                    .padding(.vertical, 25)
                    .padding(.top, 40)
                    .onChange(of: store.supportData) { supportData in
                        if supportData == nil {
                            store.send(.shareFinished)
                        }
                    }

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
                .padding(.horizontal, 60)
                .zashiBack(hidden: store.isBackButtonHidden) { store.send(.dismiss) }
                .onAppear { store.send(.onAppear) }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical, 1)
        .applyScreenBackground(withPattern: true)
        .screenTitle(L10n.ProposalPartial.title)
    }
}

private extension PartialProposalErrorView {
    @ViewBuilder func shareMessageView() -> some View {
        if store.isExportingData {
            UIShareDialogView(activityItems: [store.message]) {
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
        PartialProposalErrorView(
            store:
                StoreOf<PartialProposalError>(
                    initialState: PartialProposalError.State(
                        message: "message",
                        statuses: [],
                        txIds: [
                            "ba5113d9e78c885bdb03d44f784dc35aa0822c0f212f364b5ffc994a3e219d1f",
                            "ba5113d9e78c885bdb03d44f784dc35aa0822c0f212f364b5ffc994a3e219d1f",
                            "ba5113d9e78c885bdb03d44f784dc35aa0822c0f212f364b5ffc994a3e219d1f"
                        ]
                    )
                ) {
                    PartialProposalError()
                }
        )
    }
}

// MARK: Placeholders

extension PartialProposalError.State {
    public static let initial = PartialProposalError.State(
        message: "message",
        statuses: [],
        txIds: []
    )
}

extension PartialProposalError {
    public static let placeholder = StoreOf<PartialProposalError>(
        initialState: .initial
    ) {
        PartialProposalError()
    }
}
