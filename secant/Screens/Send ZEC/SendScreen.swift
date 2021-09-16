//
//  SendScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol SendScreenRouter: AnyObject {}

struct SendScreen: View {
    @ObservedObject var viewModel: SendScreenViewModel

    @State var router: SendScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct SendScreenScreenPreviews: PreviewProvider {
    static var previews: some View {
        SendScreen(viewModel: SendScreenViewModel(services: MockServices()))
    }
}
