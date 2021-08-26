//
//  RequestZcashScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol RequestZcashScreenRouter: AnyObject {
}

struct RequestZcashScreen: View {
    @State var router: RequestZcashScreenRouter?
    
    @ObservedObject var viewModel: RequestZcashScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RequestZcashScreenPreviews: PreviewProvider {
    static var previews: some View {
        RequestZcashScreen(viewModel: RequestZcashScreenViewModel(services: MockServices()))
    }
}
