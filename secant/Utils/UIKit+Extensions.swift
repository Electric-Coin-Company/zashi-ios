//
//  UIKit+Extensions.swift
//  secant
//
//  Created by Lukáš Korba on 09.03.2023.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
