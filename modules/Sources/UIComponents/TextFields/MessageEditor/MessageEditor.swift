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
    @Perception.Bindable var store: StoreOf<MessageEditor>

    let title: String
    let placeholder: String
    let isAddUAtoMemoActive: Bool
    
    @FocusState public var isFocused: Bool
    
    public init(
        store: StoreOf<MessageEditor>,
        title: String = L10n.Send.message,
        placeholder: String = L10n.Send.memoPlaceholder,
        isAddUAtoMemoActive: Bool = false
    ) {
        self.store = store
        self.title = title
        self.placeholder = placeholder
        self.isAddUAtoMemoActive = isAddUAtoMemoActive
        self.isFocused = false
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .zFont(.medium, size: 14, style: Design.Inputs.Filled.label)
                    .padding(.bottom, 6)
                
                VStack(spacing: 0) {
                    TextEditor(text: $store.text)
                        .focused($isFocused)
                        .font(.custom(FontFamily.Inter.regular.name, size: 16))
                        .padding(.horizontal, 10)
                        .padding(.top, 2)
                        .padding(.bottom, 10)
                        .colorBackground(Design.Inputs.Default.bg.color)
                        .cornerRadius(10)
                        .overlay {
                            if store.text.isEmpty {
                                HStack {
                                    VStack {
                                        Text(placeholder)
                                            .font(.custom(FontFamily.Inter.regular.name, size: 16))
                                            .foregroundColor(Design.Inputs.Default.text.color)
                                            .onTapGesture {
                                                isFocused = true
                                            }
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 14)
                            } else {
                                EmptyView()
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        Text(store.charLimitText)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            .foregroundColor(
                                store.isValid
                                ? Design.Inputs.Default.hint.color
                                : Design.Inputs.Filled.required.color
                            )
                            .padding(.trailing, 14)
                            .padding(.bottom, 14)
                    }
                    .frame(height: 20)
                    .padding(.top, 4)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Design.Inputs.Default.bg.color)
                }
                
                if store.featureFlags.addUAtoMemo && isAddUAtoMemoActive && !store.uAddress.isEmpty {
                    ZashiToggle(
                        isOn: $store.isUAaddedToMemo,
                        label: store.isUAaddedToMemo ? L10n.MessageEditor.addUA : L10n.MessageEditor.addUA,
                        textColor: Design.Inputs.Filled.label.color
                    )
                    .padding(.top, 12)
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
        text: ""
    )
}
