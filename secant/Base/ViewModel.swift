//
//  ViewModel.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation

open class BaseViewModel<S> {
    public var services: S
    
    public init(services: S) {
        self.services = services
    }
}
