//
//  LoadingScreen.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 9/2/21.
//

import SwiftUI

protocol LoadingScreenRouter: AnyObject {
    func proceedToHome()
    func failWithError()
    func proceedToWelcome()
}

struct LoadingScreen: View {
    @State var router: LoadingScreenRouter?
    
    @StateObject var viewModel: LoadingScreenViewModel
    
    var body: some View {
        Text("Loading")
            .onReceive(viewModel.$loadingResult, perform: { result in
                guard let loadingResult = result,
                    let router = self.router else { return }
                viewModel.callRouter(router, with: loadingResult)
            })
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    viewModel.loadAsync()
                }
            }
    }
}

// MARK: Routing

extension LoadingScreenViewModel {
    func callRouter(_ router: LoadingScreenRouter, with loadingResult: Result<LoadingScreenViewModel.LoadingResult, Error>) {
        switch loadingResult {
        case .success(let result):
            switch result {
            case .credentialsFound:
                router.proceedToHome()
            case .newWallet:
                router.proceedToWelcome()
            }
        case .failure:
            router.failWithError()
        }
    }
}

struct LoadingScreenPreviews: PreviewProvider {
    static var previews: some View {
        LoadingScreen(viewModel: LoadingScreenViewModel(services: MockServices()))
    }
}
