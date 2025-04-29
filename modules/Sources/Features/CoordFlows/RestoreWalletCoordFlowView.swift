//
//  RestoreWalletCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import RestoreInfo
import WalletBirthday

public struct RestoreWalletCoordFlowView: View {
    enum FocusTextField: Hashable {
        case field(Int)
    }

    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<RestoreWalletCoordFlow>

    @FocusState private var focusedField: FocusTextField?
    @State private var keyboardVisible: Bool = false

    public init(store: StoreOf<RestoreWalletCoordFlow>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(L10n.RestoreWallet.title)
                                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                                .padding(.top, 20)
                                .onLongPressGesture {
                                    #if DEBUG
                                    store.send(.debugPasteSeed)
                                    #endif
                                }
                            
                            Text(L10n.RestoreWallet.info)
                                .zFont(size: 14, style: Design.Text.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            
                            ForEach(0..<8, id: \.self) { j in
                                HStack(spacing: 4) {
                                    ForEach(0..<3, id: \.self) { i in
                                        HStack(spacing: 0) {
                                            Text("\(j * 3 + i + 1)")
                                                .zFont(.medium, size: 14, style: Design.Tags.tcCountFg)
                                                .frame(minWidth: 12)
                                                .padding(.vertical, 2)
                                                .padding(.horizontal, 4)
                                                .background {
                                                    RoundedRectangle(cornerRadius: Design.Radius._lg)
                                                        .fill(Design.Tags.tcCountBg.color(colorScheme))
                                                }
                                                .padding(.trailing, 4)

                                            TextField("", text: $store.words[j * 3 + i])
                                                .zFont(size: 16, style: Design.Text.primary)
                                                .disableAutocorrection(true)
                                                .textInputAutocapitalization(.never)
                                                .focused($focusedField, equals: .field((j * 3 + i)))
                                                .keyboardType(.alphabet)
                                                .submitLabel(.next)
                                                .onSubmit {
                                                    focusedField = ((j * 3 + i) < 23)
                                                    ? .field((j * 3 + i) + 1)
                                                    : .field(0)
                                                }
                                        }
                                        .padding(6)
                                        .background {
                                            RoundedRectangle(cornerRadius: Design.Radius._xl)
                                                .fill(
                                                    focusedField == .field(j * 3 + i)
                                                    ? Design.Surfaces.bgPrimary.color(colorScheme)
                                                    : Design.Surfaces.bgSecondary.color(colorScheme)
                                                )
                                                .background {
                                                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                                                        .stroke(
                                                            !store.wordsValidity[j * 3 + i]
                                                            ? Design.Inputs.ErrorFilled.stroke.color(colorScheme)
                                                            : focusedField == .field(j * 3 + i)
                                                            ? Design.Text.primary.color(colorScheme)
                                                            : Design.Surfaces.bgSecondary.color(colorScheme),
                                                            lineWidth: 2
                                                        )
                                                }
                                        }
                                        .padding(2)
                                        .padding(.bottom, 4)
                                    }
                                }
                            }
                            
                            if keyboardVisible {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                        .screenHorizontalPadding()
                    }
                    .padding(.vertical, 1)
                    
                    VStack {
                        Spacer()
                        
                        ZashiButton(L10n.General.next) {
                            store.send(.nextTapped)
                        }
                        .disabled(!store.isValidSeed)
                        .padding(.bottom, 24)
                        .screenHorizontalPadding()
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .frame(maxWidth: .infinity)
                .onAppear { observeKeyboardNotifications() }
                .onChange(of: focusedField) { handle in
                    if case .field(let index) = handle {
                        store.send(.selectedIndex(index))
                    }
                    
                    if handle == nil {
                        store.send(.selectedIndex(nil))
                    }
                }
                .onChange(of: store.nextIndex) { value in
                    if let nextIndex = value {
                        focusedField = .field(nextIndex)
                    }
                }
                .onChange(of: store.isKeyboardVisible) { value in
                    if keyboardVisible && !value {
                        keyboardVisible = value
                        focusedField = nil
                    }
                }
                .applyScreenBackground()
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()

                        Asset.Colors.primary.color
                            .frame(height: 1)
                            .opacity(0.1)
                        
                        HStack(alignment: .center) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(store.suggestedWords, id: \.self) { suggestedWord in
                                        Button {
                                            store.send(.suggestedWordTapped(suggestedWord))
                                        } label: {
                                            Text(suggestedWord)
                                                .zFont(size: 16, style: Design.Text.primary)
                                                .fixedSize()
                                                .padding(8)
                                                .background {
                                                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                                                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                                                }
                                        }
                                    }
                                }
                                .padding(.leading, 4)
                            }
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Design.Surfaces.bgSecondary.color(colorScheme).opacity(0.7), location: 0.9),
                                        .init(color: Design.Surfaces.bgSecondary.color(colorScheme).opacity(0), location: 0.98)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 38)

                            Spacer()
                            
                            Button {
                                focusedField = nil
                            } label: {
                                Text(L10n.General.done.uppercased())
                                    .zFont(.regular, size: 14, style: Design.Text.primary)
                            }
                            .padding(.trailing, 24)
                            .padding(.leading, 4)
                        }
                        .applyScreenBackground()
                        .frame(height: keyboardVisible ? 44 : 0)
                        .frame(maxWidth: .infinity)
                        .opacity(keyboardVisible ? 1 : 0)
                    }
                )
            } destination: { store in
                switch store.case {
                case let .estimateBirthdaysDate(store):
                    WalletBirthdayEstimateDateView(store: store)
                case let .estimatedBirthday(store):
                    WalletBirthdayEstimatedHeightView(store: store)
                case let .restoreInfo(store):
                    RestoreInfoView(store: store)
                case let .walletBirthday(store):
                    WalletBirthdayView(store: store)
                }
            }
            .navigationBarHidden(!store.path.isEmpty)
            .navigationBarItems(
                trailing:
                    Button {
                        store.send(.helpSheetRequested)
                    } label: {
                        Asset.Assets.Icons.help.image
                            .zImage(size: 24, style: Design.Text.primary)
                            .padding(8)
                    }
            )
            .zashiSheet(isPresented: $store.isHelpSheetPresented) {
                helpSheetContent()
                    .screenHorizontalPadding()
            }
        }
        .applyScreenBackground()
        .zashiBack()
        .screenTitle(L10n.ImportWallet.Button.restoreWallet)
    }
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = true
                store.send(.updateKeyboardFlag(true))
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = false
                store.send(.updateKeyboardFlag(false))
            }
        }
    }
    
    @ViewBuilder private func helpSheetContent() -> some View {
        Text(L10n.RestoreWallet.Help.title)
            .zFont(.semiBold, size: 24, style: Design.Text.primary)
            .padding(.top, 24)
            .padding(.bottom, 12)
        
        infoContent(text: L10n.RestoreWallet.Help.phrase)
            .padding(.bottom, 12)

        infoContent(text: L10n.RestoreWallet.Help.birthday)
            .padding(.bottom, 32)
        
        ZashiButton(L10n.RestoreInfo.gotIt) {
            store.send(.helpSheetRequested)
        }
        .padding(.bottom, 24)
    }
    
    @ViewBuilder private func infoContent(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Asset.Assets.infoCircle.image
                .zImage(size: 20, style: Design.Text.primary)
            
            if let attrText = try? AttributedString(
                markdown: text,
                including: \.zashiApp
            ) {
                ZashiText(withAttributedString: attrText, colorScheme: colorScheme)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationView {
        RestoreWalletCoordFlowView(store: RestoreWalletCoordFlow.placeholder)
    }
}

// MARK: - Placeholders

extension RestoreWalletCoordFlow.State {
    public static let initial = RestoreWalletCoordFlow.State()
}

extension RestoreWalletCoordFlow {
    public static let placeholder = StoreOf<RestoreWalletCoordFlow>(
        initialState: .initial
    ) {
        RestoreWalletCoordFlow()
    }
}
