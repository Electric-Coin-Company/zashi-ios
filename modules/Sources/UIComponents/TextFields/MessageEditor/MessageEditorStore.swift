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

@Reducer
public struct MessageEditor {
    @ObservableState
    public struct State: Equatable {
        /// default 0, no char limit
        public var charLimit = 0
        public var text = ""
        
        public var isCharLimited: Bool {
            charLimit > 0
        }
        
        public var byteLength: Int {
            // The memo supports unicode so the overall count is not char count of text
            // but byte representation instead
            text.utf8.count
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

        public init(charLimit: Int = 0, text: String = "") {
            self.charLimit = charLimit
            self.text = text
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<MessageEditor.State>)
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}
