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

public struct MessageEditor: View {
    @Environment(\.isEnabled) private var isEnabled

    let store: MessageEditorStore

    @FocusState public var isFocused: Bool
    @State private var message = ""
    
    public init(store: MessageEditorStore) {
        self.store = store
        self.isFocused = false
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                    TextEditor(text: $message)
                        .focused($isFocused)
                        .padding(2)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        .messageShape(filled: nil)
                        .colorBackground(Asset.Colors.background.color)
                        .overlay {
                            if message.isEmpty {
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
                        .onChange(of: message) { value in
                            viewStore.send(.memoInputChanged(RedactableString(message)))
                        }
                        .onAppear {
                            message = viewStore.text.data
                        }
                }
                
                if viewStore.isCharLimited {
                    HStack {
                        Spacer()
                        
                        Text(isEnabled ? viewStore.charLimitText : "")
                            .font(.custom(FontFamily.Inter.bold.name, size: 13))
                            .foregroundColor(
                                viewStore.isValid
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
        MessageEditor(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(false)
        
        MessageEditor(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(true)
    }
    .applyScreenBackground()
    .preferredColorScheme(.light)
}

#Preview {
    VStack {
        MessageEditor(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(false)
        
        MessageEditor(store: .placeholder)
            .frame(height: 200)
            .padding()
            .disabled(true)
    }
    .applyScreenBackground()
    .preferredColorScheme(.dark)
}

