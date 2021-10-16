//
//  HomeScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

protocol HomeScreenRouter: AnyObject {
    func homeScreenScanQrScreen() -> ScanQrScreen
    func homeScreenProfileScreen() -> ProfileScreen
    func homeScreenHistoryScreen() -> HistoryScreen
    func homeScreenBalanceScreen() -> BalanceScreen
    func homeScreenRequestScreen() -> RequestZcashScreen
    func homeScreenSendScreen() -> SendScreen
}

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeScreenViewModel

    @State var router: HomeScreenRouter?
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            sendButton
            requestButton
            historyButton
        }
        .padding(.horizontal, 30)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: qrCodeButton,
            trailing: profileButton
        )
    }

    @ViewBuilder var qrCodeButton: some View {
        Button(action: {}, label: {
            Image(systemName: "qrcode.viewfinder")
                .frame(width: 20, height: 20, alignment: .center)
        })
        .contentShape(Circle())
    }

    @ViewBuilder var profileButton: some View {
        Button(action: {}, label: {
            Image(systemName: "person.crop.circle")
                .frame(width: 20, height: 20, alignment: .center)
        })
        .contentShape(Circle())
    }

    @ViewBuilder var requestButton: some View {
        Button(action: {}, label: {
            Text("Request ZEC")
        })
    }

    @ViewBuilder var sendButton: some View {
        Button(action: {}, label: {
            Text("Send ZEC")
        })
    }

    @ViewBuilder var historyButton: some View {
        Button(action: {}, label: {
            Text("History")
        })
    }
}

// MARK: - Previews

struct HomeScreenPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeScreen(
                viewModel: HomeScreenViewModel.mockWithValues(
                    services: MockServices(),
                    status: .offline,
                    balance: mockBalance,
                    fiatConversion: 1.12453
                )
            )
        }
    }

    static var mockBalance: WalletBalance {
        Balance(
            transaparent: ZcashFunds.noFunds,
            sapling: ZcashFunds(
                confirmed: 123456790,
                unconfirmed: 0
            ),
            orchard: ZcashFunds(
                confirmed: 0,
                unconfirmed: 0
            )
        )
    }
}
