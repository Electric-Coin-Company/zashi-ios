//
//  ImportWalletView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture

//      jeste udelat scaledWhenBigFont
//      fix button height
//      zmena tlacitek na action pro dark
//      navigaci, back nejak
//      napojit na button v onboardingu
// texty do strings file
//      back button at je jak ma byt
//      action button ma spatnou barvu title v onboardingu
// progress bar se animuje skocenim dolu, protoze je animated

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
                        
                        Text("Wallet Import")
                            .titleText()
                    }
                    
                    Text("You can import your backed up wallet by entering your backup recovery phrase (aka seed phrase) now.")
                        .paragraphText()
                        .lineSpacing(4)
                        .opacity(0.53)
                }
                .padding(18)
                
                ImportSeedEditor(store: store)
                    .frame(width: nil, height: 200, alignment: .center)
                
                Button("Import Recovery Phrase") {
                    viewStore.send(.importRecoveryPhrase)
                }
                .activeButtonStyle
                .importWalletButtonLayout()

                Button("Import a private or viewing key") {
                    viewStore.send(.importPrivateOrViewingKey)
                }
                .secondaryButtonStyle
                .importWalletButtonLayout()

                Spacer()
            }
            .navigationBarHidden(true)
            .applyScreenBackground()
            .scrollableWhenScaledUp()
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
                minHeight: 60,
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

extension ImportWalletStore {
    static let demo = Store(
        initialState: .placeholder,
        reducer: .default,
        environment: .demo
    )
}

extension ImportWalletState {
    static let placeholder = ImportWalletState(importedSeedPhrase: "")

    static let live = ImportWalletState(importedSeedPhrase: "")
}

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
