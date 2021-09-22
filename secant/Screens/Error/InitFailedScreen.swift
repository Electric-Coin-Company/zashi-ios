//
//  InitFailedScreen.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 9/2/21.
//

import SwiftUI

protocol InitFailedScreenRouter: AnyObject {
}

struct InitFailedScreen: View {
    @State var router: InitFailedScreenRouter?
    
    @ObservedObject var viewModel: InitFailedScreenViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct InitFailedScreenPreviews: PreviewProvider {
    static var previews: some View {
        InitFailedScreen(viewModel: InitFailedScreenViewModel(services: MockServices()))
    }
}
