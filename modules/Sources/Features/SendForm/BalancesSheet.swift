//
//  BalancesSheet.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-26-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

import BalanceBreakdown

extension SendFormView {
    @ViewBuilder func balancesContent() -> some View {
        WithPerceptionTracking {
            //VStack(alignment: .leading, spacing: 0) {
                BalancesView(
                    store:
                        store.scope(
                            state: \.balancesState,
                            action: \.balances
                        ),
                    tokenName: tokenName
                )
                

            
//                .padding(.top, 32)
//            }
            //.applyScreenBackground()
//            if #available(iOS 16.0, *) {
//                balancesMainBody()
//                    .presentationDetents([.height(balancesSheetHeight)])
//                    .presentationDragIndicator(.visible)
//            } else {
//                balancesMainBody(stickToBottom: true)
//            }
        }
    }
//    
//    @ViewBuilder func balancesMainBody(stickToBottom: Bool = false) -> some View {
//        .background {
//            GeometryReader { proxy in
//                Color.clear
//                    .task {
//                        balancesSheetHeight = proxy.size.height
//                    }
//            }
//        }
//    }
}
