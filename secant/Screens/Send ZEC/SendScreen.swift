//
//  SendScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol SendScreenRouter: AnyObject {
}

struct SendScreen: View {
    @State var router: SendScreenRouter?
    
    @ObservedObject var viewModel: SendScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SendScreenScreenPreviews: PreviewProvider {
    static var previews: some View {
        SendScreen(viewModel: SendScreenViewModel(services: MockServices()))
    }
}
