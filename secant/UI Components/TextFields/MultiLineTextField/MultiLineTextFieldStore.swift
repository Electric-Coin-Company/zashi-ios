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

typealias MultiLineTextFieldStore = Store<MultiLineTextFieldReducer.State, MultiLineTextFieldReducer.Action>
typealias MultiLineTextFieldViewStore = ViewStore<MultiLineTextFieldReducer.State, MultiLineTextFieldReducer.Action>

struct MultiLineTextFieldReducer: ReducerProtocol {
    struct State: Equatable {
        /// default 0, no char limit
        var charLimit = 0
        var text = "".redacted
        
        var isCharLimited: Bool {
            charLimit > 0
        }
        
        var textLength: Int {
            text.data.count
        }
        
        var isValid: Bool {
            charLimit > 0
            ? textLength <= charLimit
            : true
        }
        
        var charLimitText: String {
            charLimit > 0
            ? isValid
            ? "\(textLength)/\(charLimit)"
            : "\(L10n.Field.Multiline.charLimitExceeded) \(textLength)/\(charLimit)"
            : ""
        }
    }

    enum Action: Equatable {
        case memoInputChanged(RedactableString)
    }
    
    var body: some ReducerProtocol<State, Action> {
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
    static let placeholder = MultiLineTextFieldStore(
        initialState: .placeholder,
        reducer: MultiLineTextFieldReducer()
    )
}

// MARK: - Placeholders

extension MultiLineTextFieldReducer.State {
    static let placeholder: MultiLineTextFieldReducer.State = {
        var state = MultiLineTextFieldReducer.State()
        state.text = "".redacted
        return state
    }()
}
