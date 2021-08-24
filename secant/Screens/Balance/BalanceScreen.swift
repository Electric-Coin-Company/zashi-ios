//
//  BalanceScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol BalanceScreenRouter: AnyObject {
}

struct BalanceScreen: View {
    @State var router: BalanceScreenRouter?
    
    @ObservedObject var viewModel: BalanceScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BalanceScreenPreviews: PreviewProvider {
    static var previews: some View {
        BalanceScreen(viewModel: BalanceScreenViewModel(services: MockServices()))
    }
}
