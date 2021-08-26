//
//  RestoreWalletScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

protocol RestoreWalletScreenRouter: AnyObject {
}

struct RestoreWalletScreen: View {
    @State var router: RestoreWalletScreenRouter?
    
    @ObservedObject var viewModel: RestoreWalletScreenViewModel
    
    var body: some View {
        VStack {
            Text("Enter Seed Phrase")
            
            TextEditor(text: $viewModel.seedText)
            
            Button(action: {}, label: {
                Text("Restore Seed Phrase")
            })
            .buttonStyle(PlainButton())
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .navigationBarTitle(Text("Restore Wallet"), displayMode: .inline)
    }
}

struct RestoreWalletScreenPreviews: PreviewProvider {
    static var previews: some View {
        RestoreWalletScreen(viewModel: RestoreWalletScreenViewModel(services: MockServices()))
    }
}
