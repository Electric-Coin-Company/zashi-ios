//
//  MultiLineTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Utils
import Generated

public typealias MultiLineTextFieldStore = Store<MultiLineTextFieldReducer.State, MultiLineTextFieldReducer.Action>
public typealias MultiLineTextFieldViewStore = ViewStore<MultiLineTextFieldReducer.State, MultiLineTextFieldReducer.Action>

public struct MultiLineTextFieldReducer: ReducerProtocol {
    public struct State: Equatable {
        /// default 0, no char limit
        public var charLimit = 0
        public var text = "".redacted
        
        public var isCharLimited: Bool {
            charLimit > 0
        }
        
        public var textLength: Int {
            text.data.count
        }
        
        public var isValid: Bool {
            charLimit > 0
            ? textLength <= charLimit
            : true
        }
        
        public var charLimitText: String {
            charLimit > 0
            ? isValid
            ? "\(textLength)/\(charLimit)"
            : "\(L10n.Field.Multiline.charLimitExceeded) \(textLength)/\(charLimit)"
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

// MARK: - ViewStore

extension MultiLineTextFieldViewStore {
    func bindingForRedactableMemo(_ memo: RedactableString) -> Binding<String> {
        self.binding(
            get: { _ in memo.data },
            send: { .memoInputChanged($0.redacted) }
        )
    }
}

// MARK: - Store

extension MultiLineTextFieldStore {
    public static let placeholder = MultiLineTextFieldStore(
        initialState: .placeholder,
        reducer: MultiLineTextFieldReducer()
    )
}

// MARK: - Placeholders

extension MultiLineTextFieldReducer.State {
    public static let placeholder: MultiLineTextFieldReducer.State = {
        var state = MultiLineTextFieldReducer.State()
        state.text = "".redacted
        return state
    }()
}
