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
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<PartialProposalError>
    
    public init(store: StoreOf<PartialProposalError>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        Asset.Assets.Icons.partial.image
                            .resizable()
                            .frame(width: 90, height: 90)
                            .padding(.top, 40)

                        Text(L10n.ProposalPartial.title)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .padding(.top, 16)

                        Group {
                            Text(L10n.ProposalPartial.message1)
                            Text(L10n.ProposalPartial.message2)
                        }
                        .zFont(size: 14, style: Design.Text.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                        HStack(spacing: 0) {
                            Text(L10n.ProposalPartial.transactionIds)
                                .zFont(.medium, size: 14, style: Design.Text.primary)

                            Spacer()
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 4)

                        ForEach(store.txIds, id: \.self) { txId in
                            Text(txId)
                                .zFont(size: 16, style: Design.Inputs.Default.text)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Design.Inputs.Default.bg.color(colorScheme))
                                }
                                .padding(.bottom, 8)
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
                    .zashiBack(hidden: store.isBackButtonHidden) { store.send(.dismiss) }
                    .onAppear { store.send(.onAppear) }
                }
                .padding(.vertical, 1)

                Spacer()
                
                ZashiButton(
                    L10n.ProposalPartial.copyIds,
                    type: .tertiary,
                    prefixView:
                        Asset.Assets.copy.image
                            .zImage(size: 20, style: Design.Btns.Ghost.fg)
                ) {
                    store.send(.copyToPastboard)
                }
                .padding(.bottom, 8)

                ZashiButton(L10n.ErrorPage.Action.contactSupport) {
                    store.send(.sendSupportMail)
                }
                .padding(.bottom, 24)
                .onChange(of: store.supportData) { supportData in
                    if supportData == nil {
                        store.send(.shareFinished)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .screenHorizontalPadding()
        .applyFailureScreenBackground()
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
