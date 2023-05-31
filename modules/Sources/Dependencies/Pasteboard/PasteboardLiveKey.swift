//
//  PasteboardLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import UIKit

extension PasteboardClient: DependencyKey {
    public static let liveValue = Self(
        setString: { UIPasteboard.general.string = $0.data },
        getString: { UIPasteboard.general.string?.redacted }
    )
}
