//
//  TransactionState.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 26.04.2022.
//

import Foundation
import ZcashLightClientKit

/// Representation of the transaction on the SDK side, used as a bridge to the TCA wallet side. 
struct TransactionState: Equatable, Identifiable {
    enum Status: Equatable {
        case paid(success: Bool)
        case received
        case failed
        case pending
    }

    var errorMessage: String?
    var expirationHeight = -1
    var memo: Memo?
    var minedHeight = -1
    var shielded = true
    var zAddress: String?

    var fee: Zatoshi
    var id: String
    var status: Status
    var timestamp: TimeInterval
    var zecAmount: Zatoshi

    var address: String { zAddress ?? "" }
    var date: Date { Date(timeIntervalSince1970: timestamp) }
    var totalAmount: Zatoshi { Zatoshi(zecAmount.amount + fee.amount) }
    var viewOnlineURL: URL? {
        URL(string: "https://zcashblockexplorer.com/transactions/\(id)")
    }

    func confirmationsWith(_ latestMinedHeight: BlockHeight?) -> BlockHeight {
        guard let latestMinedHeight = latestMinedHeight, minedHeight > 0, latestMinedHeight > 0 else {
            return 0
        }
        
        return latestMinedHeight - minedHeight
    }
}

extension TransactionState {
    init(confirmedTransaction: ConfirmedTransactionEntity, sent: Bool = false) {
        timestamp = confirmedTransaction.blockTimeInSeconds
        id = confirmedTransaction.transactionEntity.transactionId.toHexStringTxId()
        shielded = true
        status = sent ? .paid(success: confirmedTransaction.minedHeight > 0) : .received
        zAddress = confirmedTransaction.toAddress
        zecAmount = sent ? Zatoshi(-confirmedTransaction.value.amount) : confirmedTransaction.value
        fee = Zatoshi(10)
        if let memoData = confirmedTransaction.memo {
            self.memo = try? Memo(bytes: Array(memoData))
        }
        minedHeight = confirmedTransaction.minedHeight
    }
    
    init(pendingTransaction: PendingTransactionEntity, latestBlockHeight: BlockHeight? = nil) {
        timestamp = pendingTransaction.createTime
        id = pendingTransaction.rawTransactionId?.toHexStringTxId() ?? String(pendingTransaction.createTime)
        shielded = true
        status = pendingTransaction.errorMessage != nil ? .failed :
        pendingTransaction.minedHeight > 0 ?
            .paid(success: pendingTransaction.isSubmitSuccess) :
            .pending
        expirationHeight = pendingTransaction.expiryHeight
        zecAmount = pendingTransaction.value
        fee = Zatoshi(10)
        if let memoData = pendingTransaction.memo {
            self.memo = try? Memo(bytes: Array(memoData))
        }
        minedHeight = pendingTransaction.minedHeight
        errorMessage = pendingTransaction.errorMessage

        switch pendingTransaction.recipient {
        case let .address(recipient):
            zAddress = recipient.stringEncoded
        case .internalAccount:
            zAddress = nil
        }
    }
}

// MARK: - Placeholders

extension TransactionState {
    static func placeholder(
        amount: Zatoshi,
        fee: Zatoshi,
        shielded: Bool = true,
        status: Status = .received,
        timestamp: TimeInterval,
        uuid: String = UUID().debugDescription
    ) -> TransactionState {
        .init(
            expirationHeight: -1,
            memo: nil,
            minedHeight: -1,
            shielded: shielded,
            zAddress: nil,
            fee: fee,
            id: uuid,
            status: status,
            timestamp: timestamp,
            zecAmount: status == .received ? amount : Zatoshi(-amount.amount)
        )
    }
}

struct TransactionStateMockHelper {
    var date: TimeInterval
    var amount: Zatoshi
    var shielded = true
    var status: TransactionState.Status = .received
    var uuid = ""
}
