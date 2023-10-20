//
//  SecurityWarningView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 1/6/22.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import RecoveryPhraseDisplay

public struct SecurityWarningView: View {
    var store: SecurityWarningStore
    
    public init(store: SecurityWarningStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center) {
                Asset.Assets.zashiLogo.image
                    .resizable()
                    .renderingMode(.template)
                    .tint(Asset.Colors.primary.color)
                    .frame(width: 33, height: 43)
                    .padding(.bottom, 40)
                    .padding(.top, 30)
                
                Text(L10n.SecurityWarning.title)
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .padding(.bottom, 8)

                Group {
                    Text(L10n.SecurityWarning.warningPart1a(viewStore.appVersion, viewStore.appBuild))
                    + Text("[\(L10n.SecurityWarning.warningPart1b)](https://z.cash/privacy-policy/)")
                        .underline()
                    + Text(L10n.SecurityWarning.warningPart1c)
                    + Text(L10n.SecurityWarning.warningPart2)
                        .font(.custom(FontFamily.Inter.bold.name, size: 16))
                    + Text(L10n.SecurityWarning.warningPart3)
                }
                .font(.custom(FontFamily.Inter.medium.name, size: 16))
                .accentColor(.black)

                HStack {
                    Toggle(isOn: viewStore.binding(\.$isAcknowledged), label: {
                        Text(L10n.SecurityWarning.acknowledge)
                            .font(.custom(FontFamily.Inter.medium.name, size: 14))
                    })
                    .toggleStyle(CheckboxToggleStyle())
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(L10n.SecurityWarning.confirm.uppercased()) {
                    viewStore.send(.confirmTapped)
                }
                .zcashStyle()
                .disabled(!viewStore.isAcknowledged)
                .padding(.bottom, 50)
            }
            .zashiBack()
            .padding(.horizontal, 60)
            .applyScreenBackground()
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.createNewWallet),
                destination: {
                    RecoveryPhraseDisplayView(
                        store: store.scope(
                            state: \.recoveryPhraseDisplayState,
                            action: SecurityWarningReducer.Action.recoveryPhraseDisplay
                        )
                    )
                }
            )
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

// MARK: - Previews

#Preview {
    SecurityWarningView(store: .demo)
}
