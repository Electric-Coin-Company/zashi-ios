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
import RestoreInfo

public struct ImportWalletView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private enum InputID: Hashable {
        case seed
    }
    
    @Perception.Bindable var store: StoreOf<ImportWallet>

    @FocusState public var isFocused: Bool
    
    public init(store: StoreOf<ImportWallet>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            ScrollViewReader { value in
                WithPerceptionTracking {
                    VStack(alignment: .center) {
                        ZashiIcon()
                        
                        Text(L10n.ImportWallet.description)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                            .foregroundColor(Asset.Colors.primary.color)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        Text(L10n.ImportWallet.message)
                            .font(.custom(FontFamily.Inter.medium.name, size: 14))
                            .foregroundColor(Asset.Colors.primary.color)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 10)
                        
                        WithPerceptionTracking {
                            TextEditor(text: $store.importedSeedPhrase)
                                .autocapitalization(.none)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.Surfaces.strokePrimary.color(colorScheme))
                                }
                                .colorBackground(Asset.Colors.background.color)
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
                        }
                        .overlay {
                            WithPerceptionTracking {
                                if store.importedSeedPhrase.isEmpty {
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
                                        .padding(.top, 18)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 18)
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                        .onChange(of: isFocused) { update in
                            withAnimation {
                                if update {
                                    value.scrollTo(InputID.seed, anchor: .center)
                                }
                            }
                        }
                        
                        ZashiButton(L10n.General.next) {
                            store.send(.nextPressed)
                        }
                        .disabled(!store.isValidForm)
                        .padding(.top, 50)
                    }
                    .onAppear(perform: { store.send(.onAppear) })
                    .navigationLinkEmpty(
                        isActive: store.bindingFor(.birthday),
                        destination: { ImportBirthdayView(store: store) }
                    )
                    .navigationLinkEmpty(
                        isActive: Binding(
                            get: { store.state.restoreInfoViewBinding },
                            set: { store.send(.restoreInfoRequested($0)) }
                        ),
                        destination: {
                            RestoreInfoView(
                                store: store.scope(
                                    state: \.restoreInfoState,
                                    action: \.restoreInfo
                                )
                            )
                        }
                    )
                    .alert(store: store.scope(
                        state: \.$alert,
                        action: \.alert
                    ))
                    .zashiBack()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical, 1)
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
}

extension ImportWalletView {
    func mnemonicStatus() -> some View {
        WithPerceptionTracking {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(store.mnemonicStatus)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 14)
                        )
                        .foregroundColor(
                            store.isValidNumberOfWords 
                            ? Asset.Colors.primary.color 
                            : Asset.Colors.primary.color
                        )
                        .padding(.trailing, 35)
                        .padding(.bottom, 15)
                        .zIndex(1)
                }
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

// MARK: - Bindings

extension StoreOf<ImportWallet> {
    func bindingFor(_ destination: ImportWallet.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}

// MARK: - Placeholders

extension ImportWallet.State {
    public static let initial = ImportWallet.State(restoreInfoState: .initial)
}

extension StoreOf<ImportWallet> {
    public static let demo = Store(
        initialState: .initial
    ) {
        ImportWallet()
    }
}
