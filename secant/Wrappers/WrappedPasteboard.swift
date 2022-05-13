//
//  WrappedPasteboard.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import UIKit

struct WrappedPasteboard {
    let setString: (String) -> Void
    let getString: () -> String?
}

extension WrappedPasteboard {
    private struct TestPasteboard {
        static var general = TestPasteboard()
        var string: String?
    }
    
    static let live = WrappedPasteboard(
        setString: { UIPasteboard.general.string = $0 },
        getString: { UIPasteboard.general.string }
    )
    
    static let test = WrappedPasteboard(
        setString: { TestPasteboard.general.string = $0 },
        getString: { TestPasteboard.general.string }
    )
}
