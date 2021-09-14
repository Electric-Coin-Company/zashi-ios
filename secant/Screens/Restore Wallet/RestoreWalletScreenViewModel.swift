//
//  RestoreWalletScreenViewModel.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import Combine
import Foundation

class RestoreWalletScreenViewModel: BaseViewModel<Services>, ObservableObject {
    @Published var seedText: String = ""

    func restore() {}
}
