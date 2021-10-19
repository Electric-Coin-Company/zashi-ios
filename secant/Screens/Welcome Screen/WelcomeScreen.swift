//
//  CreateNewWalletScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

protocol WelcomeScreenRouter: AnyObject {}

struct WelcomeScreen: View {
    @ObservedObject var viewModel: WelcomeScreenViewModel

    @State var router: WelcomeScreenRouter?

    var body: some View {
        VStack {
            Spacer()

            Text("Welcome and Onboarding")

            Spacer()

            VStack(alignment: .center, spacing: 16) {
                Button(action: {
                    self.viewModel.restoreWallet()
                }, label: {
                    Text("RESTORE WALLET")
                })
                .primaryButtonStyle
                .frame(height: 50)

                Button(action: {
                    self.viewModel.createNew()
                }, label: {
                    Text("CREATE NEW WALLET")
                })
                .primaryButtonStyle
                .frame(height: 50)
            }
        }
        .padding()
    }
}

struct CreateNewWalletScreenPreviews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(viewModel: WelcomeScreenViewModel(services: MockServices()))
    }
}
