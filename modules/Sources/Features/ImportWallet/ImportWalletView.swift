//
//  ImportWalletView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ImportWalletView: View {
    var store: ImportWalletStore

    @FocusState private var seedFieldFocused: Bool
    
    public init(store: ImportWalletStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            WithViewStore(store) { viewStore in
                VStack(alignment: .center) {
                    ZashiIcon()
                        .padding(.vertical, 30)
                    
                    Text(L10n.ImportWallet.description)
                        .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                        .foregroundColor(Asset.Colors.primary.color)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    
                    Text(L10n.ImportWallet.message)
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(Asset.Colors.primary.color)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 10)
                    
                    ImportSeedEditor(store: store)
                        .frame(minWidth: 270)
                        .frame(height: 215)
                        .focused($seedFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                
                                Button(L10n.General.done.uppercased()) {
                                    seedFieldFocused = false
                                }
                                .foregroundColor(Asset.Colors.primary.color)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            }
                        }
                    
                    Button(L10n.General.next.uppercased()) {
                        viewStore.send(.updateDestination(.birthday))
                    }
                    .zcashStyle()
                    .frame(width: 236)
                    .disabled(!viewStore.isValidForm)
                    .padding(.top, 50)
                }
                .applyScreenBackground()
                .padding(.horizontal, 70)
                .onAppear(perform: { viewStore.send(.onAppear) })
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForDestination(.birthday),
                    destination: { ImportBirthdayView(store: store) }
                )
                .alert(store: store.scope(
                    state: \.$alert,
                    action: { .alert($0) }
                ))
                .zashiBack()
            }
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
                    .font(
                        .custom(FontFamily.Inter.regular.name, size: 14)
                    )
                    .foregroundColor(
                        viewStore.isValidNumberOfWords ?
                        Asset.Colors.primary.color :
                        Asset.Colors.primary.color
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

#Preview {
    NavigationView {
        ImportWalletView(store: .demo)
    }
}
