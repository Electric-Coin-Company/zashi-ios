//
//  PasteboardLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import UIKit

extension PasteboardClient: DependencyKey {
    static let liveValue = Self(
        setString: { UIPasteboard.general.string = $0 },
        getString: { UIPasteboard.general.string }
    )
}
