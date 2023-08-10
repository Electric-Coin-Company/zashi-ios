import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Utils

public struct CreateTransaction: View {
    let store: SendFlowStore
    let tokenName: String

    public init(store: SendFlowStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        UITextView.appearance().backgroundColor = .clear

        return WithViewStore(store) { viewStore in
            VStack(spacing: 5) {
                VStack(spacing: 0) {
                    Text(L10n.Balance.available(viewStore.shieldedBalance.data.verified.decimalString(), tokenName))
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 26)
                            .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                    Text(L10n.Send.fundsInfo)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 14)
                        )
                }
                .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    TransactionAddressTextField(
                        store: store.scope(
                            state: \.transactionAddressInputState,
                            action: SendFlowReducer.Action.transactionAddressInput
                        )
                    )
                    
                    if viewStore.isInvalidAddressFormat {
                        Text(L10n.Send.Error.invalidAddress)
                            .foregroundColor(Asset.Colors.Mfp.error.color)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)

                VStack(alignment: .leading) {
                    TransactionAmountTextField(
                        store: store.scope(
                            state: \.transactionAmountInputState,
                            action: SendFlowReducer.Action.transactionAmountInput
                        ),
                        tokenName: tokenName
                    )

                    if viewStore.isInvalidAmountFormat {
                        Text(L10n.Send.Error.invalidAmount)
                            .foregroundColor(Asset.Colors.Mfp.error.color)
                    } else if viewStore.isInsufficientFunds {
                        Text(L10n.Send.Error.insufficientFunds)
                            .foregroundColor(Asset.Colors.Mfp.error.color)
                    }
                }
                .padding(.horizontal)

                Button {
                    viewStore.send(.updateDestination(.memo))
                } label: {
                    Text(
                        viewStore.memoState.textLength > 0 ?
                        L10n.Send.editMemo
                        : L10n.Send.includeMemo
                    )
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
                .padding(.top, 10)
                .disable(when: !viewStore.isMemoInputEnabled, dimmingOpacity: 0.5)

                Button(
                    action: { viewStore.send(.sendPressed) },
                    label: { Text(L10n.General.send) }
                )
                .activeButtonStyle
                .disable(when: !viewStore.isValidForm, dimmingOpacity: 0.5)
                .padding(.top, 10)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(L10n.Send.title)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
        }
    }
}

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: ( false )
            ) { _ in
                CreateTransaction(store: .placeholder, tokenName: "ZEC")
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
        }
    }
}
