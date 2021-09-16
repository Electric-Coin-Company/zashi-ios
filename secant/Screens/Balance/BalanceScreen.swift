//
//  BalanceScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol BalanceScreenRouter: AnyObject {}

struct BalanceScreen: View {
    @ObservedObject var viewModel: BalanceScreenViewModel

    @State var router: BalanceScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct BalanceScreenPreviews: PreviewProvider {
    static var previews: some View {
        BalanceScreen(viewModel: BalanceScreenViewModel(services: MockServices()))
    }
}
