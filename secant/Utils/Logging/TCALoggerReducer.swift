//
//  TCALoggerReducer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 23.01.2023.
//

import ComposableArchitecture
import ZcashLightClientKit

extension ReducerProtocol {
    @inlinable
    public func logging(
        _ logger: ReducerLogger<State, Action>? = .tcaLogger
    ) -> LogChangesReducer<Self> {
        LogChangesReducer<Self>(base: self, logger: logger)
    }
}

public struct ReducerLogger<State, Action> {
    private let _logChange: (_ receivedAction: Action, _ oldState: State, _ newState: State) -> Void
    
    public init(
        logChange: @escaping (_ receivedAction: Action, _ oldState: State, _ newState: State) -> Void
    ) {
        self._logChange = logChange
    }
    
    public func logChange(receivedAction: Action, oldState: State, newState: State) {
        self._logChange(receivedAction, oldState, newState)
    }
}

extension ReducerLogger {
    public static var tcaLogger: Self {
        Self { receivedAction, oldState, newState in
            var target = ""
            target.write("received action:\n")
            CustomDump.customDump(receivedAction, to: &target, indent: 2)
            target.write("\n")
            target.write(diff(oldState, newState).map { "\($0)\n" } ?? "  (No state changes)\n")
            OSLogger.live.tcaDebug("\(target)")
        }
    }
}

public struct LogChangesReducer<Base: ReducerProtocol>: ReducerProtocol {
    @usableFromInline let base: Base
    
    @usableFromInline let logger: ReducerLogger<Base.State, Base.Action>?
    
    @usableFromInline
    init(base: Base, logger: ReducerLogger<Base.State, Base.Action>?) {
        self.base = base
        self.logger = logger
    }
    
    @inlinable
    public func reduce(
        into state: inout Base.State, action: Base.Action
    ) -> EffectTask<Base.Action> {
        guard let logger else {
            return self.base.reduce(into: &state, action: action)
        }
        
        let oldState = state
        let effects = self.base.reduce(into: &state, action: action)
        return effects.merge(
            with: .fireAndForget { [newState = state] in
                logger.logChange(receivedAction: action, oldState: oldState, newState: newState)
            }
        )
    }
}
