//
//  ImportWalletView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture

struct ImportWalletView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var store: ImportWalletStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Button("Back") { presentationMode.wrappedValue.dismiss() }
                        .navigationButtonStyle
                        .frame(width: 75, height: 40)
                        
                        Text("importWallet.title")
                            .titleText()
                    }
                    
                    Text("importWallet.description")
                        .paragraphText()
                        .lineSpacing(4)
                        .opacity(0.53)
                }
                .padding(18)
                
                ZStack {
                    ImportSeedEditor(store: store)
                    
                    mnemonicStatus(viewStore)
                }
                .frame(width: nil, height: 200, alignment: .center)

                VStack {
                    Text("importWallet.birthday.description")
                        .paragraphText()

                    TextField("importWallet.birthday.placeholder", text: viewStore.binding(\.$birthdayHeight))
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .importSeedEditorModifier()
                }
                .padding(28)

                Button("importWallet.button.restoreWallet") {
                    viewStore.send(.restoreWallet)
                }
                .activeButtonStyle
                .importWalletButtonLayout()
                .disabled(!viewStore.isValidForm)

                Button("importWallet.button.importPrivateKey") {
                    viewStore.send(.importPrivateOrViewingKey)
                }
                .secondaryButtonStyle
                .importWalletButtonLayout()

                Spacer()
            }
            .navigationBarHidden(true)
            .applyScreenBackground()
            .scrollableWhenScaledUp()
            .onAppear(perform: { viewStore.send(.onAppear) })
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
        }
    }
}

extension ImportWalletView {
    func mnemonicStatus(_ viewStore: ImportWalletViewStore) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(viewStore.mnemonicStatus)
                    .font(.custom(FontFamily.Rubik.regular.name, size: 14))
                    .foregroundColor(
                        viewStore.isValidNumberOfWords ?
                        Asset.Colors.Text.validMnemonic.color :
                            Asset.Colors.Text.heading.color
                    )
                    .padding(.trailing, 35)
                    .padding(.bottom, 15)
                    .zIndex(1)
            }
        }
    }
}

// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate struct ImportWalletButtonLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 64,
                maxHeight: .infinity,
                alignment: .center
            )
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 28)
            .transition(.opacity)
    }
}

extension View {
    func importWalletButtonLayout() -> some View {
        modifier(ImportWalletButtonLayout())
    }
}

// MARK: - Previews

struct ImportWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletView(store: .demo)
            .preferredColorScheme(.light)

        ImportWalletView(store: .demo)
            .preferredColorScheme(.dark)
        
        ImportWalletView(store: .demo)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .preferredColorScheme(.light)
            .environment(\.sizeCategory, .accessibilityLarge)
    }
}
