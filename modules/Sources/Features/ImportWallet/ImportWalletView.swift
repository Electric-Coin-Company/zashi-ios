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
import Utils

public struct ImportWalletView: View {
    private enum InputID: Hashable {
        case seed
    }
    
    var store: ImportWalletStore

    @FocusState public var isFocused: Bool
    @State private var message = ""
    
    public init(store: ImportWalletStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            ScrollViewReader { value in
                WithViewStore(store, observe: { $0 }) { viewStore in
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
                        
                        TextEditor(text: $message)
                            .autocapitalization(.none)
                            .recoveryPhraseShape()
                            .frame(minWidth: 270)
                            .frame(height: 215)
                            .focused($isFocused)
                            .id(InputID.seed)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    
                                    Button(L10n.General.done.uppercased()) {
                                        isFocused = false
                                    }
                                    .foregroundColor(Asset.Colors.primary.color)
                                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                }
                            }
                            .overlay {
                                if message.isEmpty {
                                    HStack {
                                        VStack {
                                            Text(L10n.ImportWallet.enterPlaceholder)
                                                .font(.custom(FontFamily.Inter.regular.name, size: 13))
                                                .foregroundColor(Asset.Colors.shade72.color)
                                                .onTapGesture {
                                                    isFocused = true
                                                }
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 10)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                } else {
                                    EmptyView()
                                }
                            }
                            .onChange(of: message) { value in
                                viewStore.send(.seedPhraseInputChanged(RedactableString(message)))
                            }
                            .onChange(of: isFocused) { update in
                                withAnimation {
                                    if update {
                                        value.scrollTo(InputID.seed, anchor: .center)
                                    }
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
        .padding(.vertical, 1)
        .applyScreenBackground()
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
