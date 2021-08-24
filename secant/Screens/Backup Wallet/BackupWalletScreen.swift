//
//  BackupWalletScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

protocol BackupWalletScreenRouter: AnyObject {
}

struct BackupWalletScreen: View {
    @State var router: BackupWalletScreenRouter?
    
    @ObservedObject var viewModel: BackupWalletScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BackupWalletScreenPreviews: PreviewProvider {
    static var previews: some View {
        BackupWalletScreen(viewModel: BackupWalletScreenViewModel(services: MockServices()))
    }
}
