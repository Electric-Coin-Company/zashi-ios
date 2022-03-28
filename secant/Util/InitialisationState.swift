//
//  InitialisationState.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.03.2022.
//

import Foundation

enum InitialisationState: Equatable {
    case failure(ErrorWrapper)
    case initialized
    case keysMissingFilesPresent
    case keysPresentFilesMissing
    case uninitialized
}
