//
//  NotEnoughFreeSpace.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import UIComponents
import Generated

public struct NotEnoughFreeSpaceView: View {
    let viewStore: HomeViewStore
    
    public init(viewStore: HomeViewStore) {
        self.viewStore = viewStore
    }
    
    public var body: some View {
        Text(L10n.Nefs.message)
            .applyScreenBackground()
    }
}

// MARK: - Previews

struct NotEnoughFreeSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NotEnoughFreeSpaceView(viewStore: ViewStore(HomeStore.placeholder, observe: { $0 }))
    }
}
