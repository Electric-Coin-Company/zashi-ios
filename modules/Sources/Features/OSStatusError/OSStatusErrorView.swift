//
//  OSStatusErrorView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-11-20.
//

import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents

public struct OSStatusErrorView: View {
    @Perception.Bindable var store: StoreOf<OSStatusError>
    
    public init(store: StoreOf<OSStatusError>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Spacer()
                
                Asset.Assets.infoCircle.image
                    .zImage(size: 28, style: Design.Utility.ErrorRed._700)
                    .padding(18)
                    .background {
                        Circle()
                            .fill(Design.Utility.ErrorRed._100.color)
                    }
                    .rotationEffect(.degrees(180))

                Text("It’s not you, it’s us.")
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                Text("Your funds are safe but something happened while we were trying to retrieve the Keychain data. Close the Zashi app, and give it a fresh launch, we will try again.")
                    .zFont(size: 14, style: Design.Text.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(1.5)
                    .padding(.bottom, 12)

                Text("Error code: \(String(format: "%d", store.osStatus))")
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.bottom, 100)

                Spacer()
                
                ZashiButton(L10n.ProposalPartial.contactSupport) {
                    store.send(.sendSupportMail)
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
            .frame(maxWidth: .infinity)
            .onAppear { store.send(.onAppear) }
            .screenHorizontalPadding()
            .applyErredScreenBackground()
        }
    }
}

private extension OSStatusErrorView {
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

// MARK: - Previews

#Preview {
    NavigationView {
        OSStatusErrorView(
            store:
                StoreOf<OSStatusError>(
                    initialState: OSStatusError.State(
                        message: "",
                        osStatus: errSecSuccess
                    )
                ) {
                    OSStatusError()
                }
        )
    }
}

// MARK: Placeholders

extension OSStatusError.State {
    public static let initial = OSStatusError.State(
        message: "",
        osStatus: errSecSuccess
    )
}

extension OSStatusError {
    public static let placeholder = StoreOf<OSStatusError>(
        initialState: .initial
    ) {
        OSStatusError()
    }
}
