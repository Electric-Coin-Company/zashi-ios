//
//  MessageEditor.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Utils

public extension View {
    func colorBackground(_ content: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden).background(content)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self.background(content)
        }
    }
}

public struct MessageEditorView: View {
    @Environment(\.isEnabled) private var isEnabled

    @Perception.Bindable var store: StoreOf<MessageEditor>

    @FocusState public var isFocused: Bool
    
    public init(store: StoreOf<MessageEditor>) {
        self.store = store
        self.isFocused = false
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    Asset.Assets.fly.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(Asset.Colors.primary.color)
                    
                    Text(L10n.Send.message)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    
                    Spacer()
                }
                .padding(.bottom, 2)

                if !isEnabled {
                    Asset.Colors.messageBcgDisabled.color
                        .messageShape(
                            filled: Asset.Colors.messageBcgDisabled.color,
                            border: Asset.Colors.messageBcgBorder.color
                        )
                } else {
                    TextEditor(text: store.bindingForRedactableInput(store.text))
                        .focused($isFocused)
                        .padding(2)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        .messageShape(filled: nil)
                        .colorBackground(Asset.Colors.background.color)
                        .overlay {
                            if store.text.data.isEmpty {
                                HStack {
                                    VStack {
                                        Text(L10n.Send.memoPlaceholder)
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
                }
                
                if store.isCharLimited {
                    HStack {
                        Spacer()
                        
                        Text(isEnabled ? store.charLimitText : "")
                            .font(.custom(FontFamily.Inter.bold.name, size: 13))
                            .foregroundColor(
                                store.isValid
                                ? Asset.Colors.shade72.color
                                : Design.Utility.ErrorRed._600.color
                            )
                    }
                    .frame(height: 20)
                }
            }
        }
    }
}

#Preview {
    VStack {
        MessageEditorView(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(false)
        
        MessageEditorView(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(true)
    }
    .applyScreenBackground()
    .preferredColorScheme(.light)
}

#Preview {
    VStack {
        MessageEditorView(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(false)
        
        MessageEditorView(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(true)
    }
    .applyScreenBackground()
    .preferredColorScheme(.dark)
}

// MARK: - Store

extension StoreOf<MessageEditor> {
    public static let placeholder = StoreOf<MessageEditor>(
        initialState: .initial
    ) {
        MessageEditor()
    }
}

// MARK: - Placeholders

extension MessageEditor.State {
    public static let initial = MessageEditor.State(
        charLimit: 0,
        text: .empty
    )
}

// MARK: - Bindings

extension StoreOf<MessageEditor> {
    func bindingForRedactableInput(_ input: RedactableString) -> Binding<String> {
        Binding<String>(
            get: { input.data },
            set: { self.send(.inputChanged($0.redacted)) }
        )
    }
}
