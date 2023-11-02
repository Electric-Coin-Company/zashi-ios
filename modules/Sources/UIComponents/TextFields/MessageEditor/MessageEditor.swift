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
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Asset.Assets.fly.image
                        .resizable()
                        .frame(width: 20, height: 16)
                    
                    Text(L10n.Send.message)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    
                    Spacer()
                }
                .padding(.bottom, 2)
                
                TextEditor(text: $message)
                    .focused($isFocused)
                    .padding(2)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .messageShape(filled: !isEnabled)
                    .overlay {
                        if message.isEmpty || !isEnabled {
                            HStack {
                                VStack {
                                    Text(L10n.Send.memoPlaceholder)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 13))
                                        .foregroundColor(Asset.Colors.suppressed72.color)
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
                
                if viewStore.isCharLimited {
                    HStack {
                        Spacer()
                        
                        Text(viewStore.charLimitText)
                            .font(.custom(FontFamily.Inter.bold.name, size: 13))
                            .foregroundColor(
                                viewStore.isValid
                                ? Asset.Colors.suppressed72.color
                                : Asset.Colors.error.color
                            )
                    }
                }
            }
        }
    }
}

struct MessageEditor_Previews: PreviewProvider {
    static var previews: some View {
        MessageEditor(store: .placeholder)
            .frame(height: 200)
            .padding()
            .applyScreenBackground()
            .preferredColorScheme(.light)
            .disabled(false)
    }
}
