//
//  WalletBalance+testing.swift
//  secantTests
//
//  Created by Francisco Gindre on 7/15/22.
//

import Foundation
import ZcashLightClientKit

extension WalletBalance {
    init(verified: Int, total: Int) {
        self.init(verified: Zatoshi(Int64(verified)), total: Zatoshi(Int64(verified)))
    }
}
