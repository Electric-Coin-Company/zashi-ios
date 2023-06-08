//
//  Memo+toString.swift
//  secant-testnet
//
//  Created by Michal Fousek on 18.11.2022.
//

import Foundation
import ZcashLightClientKit

extension Memo {
    func toString() -> String? {
        switch self {
        case .empty:
            return nil
        case .text(let text):
            return text.string
        case .future(let memoBytes):
            return Data(memoBytes.bytes).asZcashTransactionMemo()
        case .arbitrary(let bytes):
            return Data(bytes).asZcashTransactionMemo()
        }
    }
}
