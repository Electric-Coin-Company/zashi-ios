//
//  ScanQrScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol ScanQrScreenRouter: AnyObject {
}

struct ScanQrScreen: View {
    @State var router: ScanQrScreenRouter?
    
    @ObservedObject var viewModel: ScanQrScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ScanQrScreenScreenPreviews: PreviewProvider {
    static var previews: some View {
        ScanQrScreen(viewModel: ScanQrScreenViewModel(services: MockServices()))
    }
}
