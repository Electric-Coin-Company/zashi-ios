//
//  ScanQrScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol ScanQrScreenRouter: AnyObject {}

struct ScanQrScreen: View {
    @ObservedObject var viewModel: ScanQrScreenViewModel

    @State var router: ScanQrScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct ScanQrScreenScreenPreviews: PreviewProvider {
    static var previews: some View {
        ScanQrScreen(viewModel: ScanQrScreenViewModel(services: MockServices()))
    }
}
