//
//  MessageEditorStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Utils
import Generated

public typealias MessageEditorStore = Store<MessageEditorReducer.State, MessageEditorReducer.Action>
public typealias MessageEditorViewStore = ViewStore<MessageEditorReducer.State, MessageEditorReducer.Action>

public struct MessageEditorReducer: ReducerProtocol {
    public struct State: Equatable {
        /// default 0, no char limit
        public var charLimit = 0
        public var text = "".redacted
        
        public var isCharLimited: Bool {
            charLimit > 0
        }
        
        public var byteLength: Int {
            // The memo supports unicode so the overall count is not char count of text
            // but byte representation instead
            text.data.utf8.count
        }
        
        public var isValid: Bool {
            charLimit > 0
            ? byteLength <= charLimit
            : true
        }
        
        public var charLimitText: String {
            charLimit > 0
            ? "\(charLimit - byteLength)/\(charLimit)"
            : ""
        }

        public init(charLimit: Int = 0, text: RedactableString = "".redacted) {
            self.charLimit = charLimit
            self.text = text
        }
    }

    public enum Action: Equatable {
        case memoInputChanged(RedactableString)
    }
    
    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .memoInputChanged(let text):
                state.text = text
                return .none
            }
        }
    }
}

// MARK: - Store

extension MessageEditorStore {
    public static let placeholder = MessageEditorStore(
        initialState: .placeholder,
        reducer: MessageEditorReducer()
    )
}

// MARK: - Placeholders

extension MessageEditorReducer.State {
    public static let placeholder: MessageEditorReducer.State = {
        var state = MessageEditorReducer.State()
        state.text = "".redacted
        state.charLimit = 0
        return state
    }()
}
