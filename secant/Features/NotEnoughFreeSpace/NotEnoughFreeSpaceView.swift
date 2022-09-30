//
//  NotEnoughFreeSpace.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct NotEnoughFreeSpaceView: View {
    let viewStore: HomeViewStore
    
    var body: some View {
        Text("Not enough space on disk to do synchronisation!")
            .applyScreenBackground()
    }
}

// MARK: - Previews

struct NotEnoughFreeSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NotEnoughFreeSpaceView(viewStore: ViewStore(HomeStore.placeholder))
    }
}
