//
//  TransactionState.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 26.04.2022.
//

import Foundation
import ZcashLightClientKit

/// Representation of the transaction on the SDK side, used as a bridge to the TCA wallet side. 
public struct TransactionState: Equatable, Identifiable {
    public enum Status: Equatable {
        case paid(success: Bool)
        case received
        case failed
        case sending
        case receiving
    }

    public var errorMessage: String?
    public var expiryHeight: BlockHeight?
    public var memos: [Memo]?
    public var minedHeight: BlockHeight?
    public var shielded = true
    public var zAddress: String?

    public var fee: Zatoshi
    public var id: String
    public var status: Status
    public var timestamp: TimeInterval?
    public var zecAmount: Zatoshi

    public var address: String {
        zAddress ?? ""
    }
    
    public var unarySymbol: String {
        switch status {
        case .paid, .sending:
            return "-"
        case .received, .receiving:
            return "+"
        case .failed:
            return ""
        }
    }

    public var date: Date? {
        guard let timestamp else { return nil }
        
        return Date(timeIntervalSince1970: timestamp)
    }

    public var totalAmount: Zatoshi {
        Zatoshi(zecAmount.amount + fee.amount)
    }

    public var viewOnlineURL: URL? {
        URL(string: "https://zcashblockexplorer.com/transactions/\(id)")
    }
    
    public init(
        errorMessage: String? = nil,
        expiryHeight: BlockHeight? = nil,
        memos: [Memo]? = nil,
        minedHeight: BlockHeight? = nil,
        shielded: Bool = true,
        zAddress: String? = nil,
        fee: Zatoshi,
        id: String,
        status: Status,
        timestamp: TimeInterval? = nil,
        zecAmount: Zatoshi
    ) {
        self.errorMessage = errorMessage
        self.expiryHeight = expiryHeight
        self.memos = memos
        self.minedHeight = minedHeight
        self.shielded = shielded
        self.zAddress = zAddress
        self.fee = fee
        self.id = id
        self.status = status
        self.timestamp = timestamp
        self.zecAmount = zecAmount
    }
    
    public func confirmationsWith(_ latestMinedHeight: BlockHeight?) -> BlockHeight {
        guard let minedHeight, let latestMinedHeight, minedHeight > 0, latestMinedHeight > 0 else {
            return 0
        }
        
        return latestMinedHeight - minedHeight
    }
}

extension TransactionState {
    public init(transaction: ZcashTransaction.Overview, memos: [Memo]? = nil, latestBlockHeight: BlockHeight? = nil) {
        expiryHeight = transaction.expiryHeight
        minedHeight = transaction.minedHeight
        fee = transaction.fee ?? .zero
        id = transaction.rawID.toHexStringTxId()
        timestamp = transaction.blockTime
        zecAmount = transaction.isSentTransaction ? Zatoshi(-transaction.value.amount) : transaction.value
        self.memos = memos

        let isSent = transaction.isSentTransaction
        let isPending = transaction.isPending(currentHeight: latestBlockHeight ?? 0)
        switch (isSent, isPending) {
        case (true, true): status = .sending
        case (true, false): status = .paid(success: minedHeight ?? 0 > 0)
        case (false, true): status = .receiving
        case (false, false): status = .received
        }
    }
}

// MARK: - Placeholders

extension TransactionState {
    public static func placeholder(
        amount: Zatoshi = .zero,
        fee: Zatoshi = .zero,
        shielded: Bool = true,
        status: Status = .received,
        timestamp: TimeInterval = 0.0,
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

public struct TransactionStateMockHelper {
    public var date: TimeInterval
    public var amount: Zatoshi
    public var shielded = true
    public var status: TransactionState.Status = .received
    public var uuid = ""
    
    public init(
        date: TimeInterval,
        amount: Zatoshi,
        shielded: Bool = true,
        status: TransactionState.Status = .received,
        uuid: String = ""
    ) {
        self.date = date
        self.amount = amount
        self.shielded = shielded
        self.status = status
        self.uuid = uuid
    }
}
