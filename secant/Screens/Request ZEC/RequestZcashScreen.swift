//
//  RequestZcashScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol RequestZcashScreenRouter: AnyObject {}

struct RequestZcashScreen: View {
    @ObservedObject var viewModel: RequestZcashScreenViewModel

    @State var router: RequestZcashScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct RequestZcashScreenPreviews: PreviewProvider {
    static var previews: some View {
        RequestZcashScreen(viewModel: RequestZcashScreenViewModel(services: MockServices()))
    }
}
