//
//  BackupWalletScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

protocol BackupWalletScreenRouter: AnyObject {}

struct BackupWalletScreen: View {
    @ObservedObject var viewModel: BackupWalletScreenViewModel

    @State var router: BackupWalletScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct BackupWalletScreenPreviews: PreviewProvider {
    static var previews: some View {
        BackupWalletScreen(viewModel: BackupWalletScreenViewModel(services: MockServices()))
    }
}
