//
//  SendFeedbackView.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-11-2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Utils

public struct SendFeedbackView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<SendFeedback>
    
    public init(store: StoreOf<SendFeedback>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.SendFeedback.title)
                        .zFont(.semiBold, size: 24, style: Design.Text.primary)
                        .padding(.top, 40)
                    
                    Text(L10n.SendFeedback.desc)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 8)
                    
                    Text(L10n.SendFeedback.ratingQuestion)
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                        .padding(.top, 32)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<5) { rating in
                            WithPerceptionTracking {
                                Button {
                                    store.send(.ratingTapped(rating))
                                } label: {
                                    Text(store.ratings[rating])
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background {
                                            RoundedRectangle(cornerRadius: Design.Radius._xl)
                                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                                        }
                                        .padding(3)
                                        .overlay {
                                            if let selectedRating = store.selectedRating, selectedRating == rating {
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Design.Text.primary.color(colorScheme))
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    
                    Text(L10n.SendFeedback.howCanWeHelp)
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                        .padding(.top, 24)
                    
                    MessageEditorView(
                        store: store.memoStore(),
                        title: "",
                        placeholder: L10n.SendFeedback.hcwhPlaceholder
                    )
                    .frame(height: 155)
                    
                    if let supportData = store.supportData {
                        UIMailDialogView(
                            supportData: supportData,
                            completion: {
                                store.send(.sendSupportMailFinished)
                            }
                        )
                        // UIMailDialogView only wraps MFMailComposeViewController presentation
                        // so frame is set to 0 to not break SwiftUI's layout
                        .frame(width: 0, height: 0)
                    }
                    
                    Spacer()
                    
                    ZashiButton(
                        L10n.General.share
                    ) {
                        store.send(.sendTapped)
                    }
                    .disabled(store.invalidForm)
                    .padding(.bottom, 20)
                    
                    shareView()
                }
                .screenHorizontalPadding()
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear { store.send(.onAppear) }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .screenTitle(L10n.SendFeedback.screenTitle.uppercased())
    }
}

extension SendFeedbackView {
    @ViewBuilder func shareView() -> some View {
        if let message = store.messageToBeShared {
            UIShareDialogView(activityItems: [
                ShareableMessage(
                    title: L10n.SendFeedback.Share.title,
                    message: message,
                    desc: L10n.SendFeedback.Share.desc
                ),
            ]) {
                store.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUI's layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    SendFeedbackView(store: SendFeedback.initial)
}

// MARK: - Store

extension SendFeedback {
    public static var initial = StoreOf<SendFeedback>(
        initialState: .initial
    ) {
        SendFeedback()
    }
}

// MARK: - Placeholders

extension SendFeedback.State {
    public static let initial = SendFeedback.State()
}

extension StoreOf<SendFeedback> {
    func memoStore() -> StoreOf<MessageEditor> {
        self.scope(
            state: \.memoState,
            action: \.memo
        )
    }
}
