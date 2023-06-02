//
//  ImportWalletView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture
import Generated

struct ImportWalletView: View {
    var store: ImportWalletStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(L10n.ImportWallet.description)
                    .font(.system(size: 27))
                    .fontWeight(.bold)
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                    .minimumScaleFactor(0.3)

                ImportSeedEditor(store: store)
                    .frame(width: nil, height: 200, alignment: .center)

                Button(L10n.General.next) {
                    viewStore.send(.updateDestination(.birthday))
                }
                .activeButtonStyle
                .importWalletButtonLayout()
                .disable(
                    when: !viewStore.isValidForm,
                    dimmingOpacity: 0.5
                )

                Spacer()
            }
            .padding(.horizontal, 20)
            .applyScreenBackground()
            .scrollableWhenScaledUp()
            .onAppear(perform: { viewStore.send(.onAppear) })
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.birthday),
                destination: { ImportBirthdayView(store: store) }
            )
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
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
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .preferredColorScheme(.light)
    }
}
