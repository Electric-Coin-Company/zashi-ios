//
//  ImportBirthdayView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct ImportBirthdayView: View {
    var store: ImportWalletStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("importWallet.birthday.description")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                
                TextField(
                    "importWallet.birthday.placeholder",
                    text: viewStore.bindingForRedactableBirthday(viewStore.birthdayHeight)
                )
                .keyboardType(.numberPad)
                .autocapitalization(.none)
                .importSeedEditorModifier()
                
                Button("importWallet.button.restoreWallet") {
                    viewStore.send(.restoreWallet)
                }
                .activeButtonStyle
                .importWalletButtonLayout()
                .disabled(!viewStore.isValidForm)
                .opacity(viewStore.isValidForm ? 1.0 : 0.5)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .applyScreenBackground()
            .scrollableWhenScaledUp()
            .onAppear(perform: { viewStore.send(.onAppear) })
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
        }
    }
}

// MARK: - Previews

struct ImportBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        ImportBirthdayView(store: .demo)
            .preferredColorScheme(.light)

        ImportBirthdayView(store: .demo)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .preferredColorScheme(.light)
    }
}
