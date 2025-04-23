//
//  SignWithKeystoneCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-26.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import SendConfirmation
import Scan
import TransactionDetails

public struct SignWithKeystoneCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<SignWithKeystoneCoordFlow>
    let tokenName: String

    public init(store: StoreOf<SignWithKeystoneCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                SignWithKeystoneView(
                    store:
                        store.scope(
                            state: \.sendConfirmationState,
                            action: \.sendConfirmation
                        ),
                    tokenName: tokenName
                )
                .navigationBarHidden(true)
            } destination: { store in
                switch store.case {
                case let .preSendingFailure(store):
                    PreSendingFailureView(store: store, tokenName: tokenName)
                case let .scan(store):
                    ScanView(store: store, popoverRatio: 1.075)
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
        }
        .applyScreenBackground()
        .zashiBack()
        //.screenTitle(L10n.General.send)
    }
}

#Preview {
    NavigationView {
        SignWithKeystoneCoordFlowView(store: SignWithKeystoneCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension SignWithKeystoneCoordFlow.State {
    public static let initial = SignWithKeystoneCoordFlow.State()
}

extension SignWithKeystoneCoordFlow {
    public static let placeholder = StoreOf<SignWithKeystoneCoordFlow>(
        initialState: .initial
    ) {
        SignWithKeystoneCoordFlow()
    }
}
