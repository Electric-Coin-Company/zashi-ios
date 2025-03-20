//
//  TransactionsCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-20.
//

import ComposableArchitecture
import Generated

// Path
import TransactionDetails
import TransactionsManager

extension TransactionsCoordFlow {
    public func coordinatorReduce() -> Reduce<TransactionsCoordFlow.State, TransactionsCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - Transaction Details
                
                
                
            default: return .none
            }
        }
    }
}
