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

struct NotEnoughFreeSpaceView: View {
    let viewStore: HomeViewStore
    
    var body: some View {
        Text(L10n.Nefs.message)
            .applyScreenBackground()
    }
}

// MARK: - Previews

struct NotEnoughFreeSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NotEnoughFreeSpaceView(viewStore: ViewStore(HomeStore.placeholder))
    }
}
