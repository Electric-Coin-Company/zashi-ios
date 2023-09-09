//
//  File.swift
//  
//
//  Created by Praveen kumar Vattipalli on 09/09/23.
//

import Foundation
import ComposableArchitecture
import Models
import Pasteboard

public typealias SecurityWarningStore = Store<SecurityWarningReducer.State, SecurityWarningReducer.Action>

public struct SecurityWarningReducer: ReducerProtocol {
    public struct State: Equatable {}
    
    public enum Action: Equatable {
        case debugMenuStartup
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        return .none
    }
}

// MARK: - Store

extension SecurityWarningStore {
    public static var demo = SecurityWarningStore(
        initialState: .placeholder,
        reducer: SecurityWarningReducer()
    )
}

// MARK: - Placeholders

extension SecurityWarningReducer.State {
    public static let placeholder = SecurityWarningReducer.State()
}
