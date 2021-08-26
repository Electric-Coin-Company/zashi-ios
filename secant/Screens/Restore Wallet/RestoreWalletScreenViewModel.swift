//
//  RestoreWalletScreenViewModel.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import Foundation
import Combine

class RestoreWalletScreenViewModel: BaseViewModel<Services>, ObservableObject {
    
    @Published var seedText: String = ""
    
    func restore() {}
}
