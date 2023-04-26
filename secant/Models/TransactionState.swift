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
    var expiryHeight: BlockHeight?
    var memos: [Memo]?
    var minedHeight: BlockHeight?
    var shielded = true
    var zAddress: String?

    var fee: Zatoshi
    var id: String
    var status: Status
    var timestamp: TimeInterval?
    var zecAmount: Zatoshi

    var address: String {
        zAddress ?? ""
    }
    
    var unarySymbol: String {
        switch status {
        case .paid, .pending:
            return "-"
        case .received:
            return "+"
        case .failed:
            return ""
        }
    }

    var date: Date? {
        guard let timestamp else { return nil }
        
        return Date(timeIntervalSince1970: timestamp)
    }

    var totalAmount: Zatoshi {
        Zatoshi(zecAmount.amount + fee.amount)
    }

    var viewOnlineURL: URL? {
        URL(string: "https://zcashblockexplorer.com/transactions/\(id)")
    }
    
    func confirmationsWith(_ latestMinedHeight: BlockHeight?) -> BlockHeight {
        guard let minedHeight, let latestMinedHeight, minedHeight > 0, latestMinedHeight > 0 else {
            return 0
        }
        
        return latestMinedHeight - minedHeight
    }
}

extension TransactionState {
    init(transaction: ZcashTransaction.Overview, memos: [Memo]? = nil) {
        expiryHeight = transaction.expiryHeight
        minedHeight = transaction.minedHeight
        fee = transaction.fee ?? Zatoshi(0)
        id = transaction.rawID.toHexStringTxId()
        status = transaction.isSentTransaction ? .paid(success: minedHeight ?? 0 > 0) : .received
        timestamp = transaction.blockTime
        zecAmount = transaction.isSentTransaction ? Zatoshi(-transaction.value.amount) : transaction.value
        self.memos = memos
    }

    init(transaction: ZcashTransaction.Sent, memos: [Memo]? = nil) {
        expiryHeight = transaction.expiryHeight
        minedHeight = transaction.minedHeight
        fee = .zero
        id = transaction.rawID?.toHexStringTxId() ?? ""
        status = .paid(success: minedHeight ?? 0 > 0)
        timestamp = transaction.blockTime
        zecAmount = transaction.value
        self.memos = memos
    }

    init(transaction: ZcashTransaction.Received, memos: [Memo]? = nil) {
        expiryHeight = transaction.expiryHeight
        minedHeight = transaction.minedHeight
        fee = .zero
        id = transaction.rawID?.toHexStringTxId() ?? ""
        status = .received
        timestamp = transaction.blockTime
        zecAmount = transaction.value
        self.memos = memos
    }

    init(pendingTransaction: PendingTransactionEntity, latestBlockHeight: BlockHeight? = nil) {
        timestamp = pendingTransaction.createTime
        id = pendingTransaction.rawTransactionId?.toHexStringTxId() ?? String(pendingTransaction.createTime)
        shielded = true
        status = pendingTransaction.errorMessage != nil ? .failed :
        pendingTransaction.minedHeight > 0 ?
            .paid(success: pendingTransaction.isSubmitSuccess) :
            .pending
        expiryHeight = pendingTransaction.expiryHeight
        zecAmount = pendingTransaction.value
        fee = Zatoshi(10)
        minedHeight = pendingTransaction.minedHeight
        errorMessage = pendingTransaction.errorMessage
        if let data = pendingTransaction.memo, let memo = try? Memo(bytes: [UInt8](data)) {
            memos = [memo]
        }
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
            expiryHeight: -1,
            memos: nil,
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
