//
//  TransactionState.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 26.04.2022.
//

import Foundation
import SwiftUI
import ZcashLightClientKit
import Generated

/// Representation of the transaction on the SDK side, used as a bridge to the TCA wallet side. 
public struct TransactionState: Equatable, Identifiable {
    public enum Status: Equatable {
        case failed
        case paid
        case received
        case receiving
        case sending
        case shielding
        case shielded
    }

    public var errorMessage: String?
    public var expiryHeight: BlockHeight?
    public var memoCount: Int
    public var memos: [Memo]?
    public var minedHeight: BlockHeight?
    public var shielded = true
    public var zAddress: String?
    public var isSentTransaction: Bool
    public var isShieldingTransaction: Bool
    public var isTransparentRecipient: Bool

    public var fee: Zatoshi?
    public var id: String
    public var status: Status
    public var timestamp: TimeInterval?
    public var zecAmount: Zatoshi

    public var isAddressExpanded: Bool
    public var isExpanded: Bool
    public var isIdExpanded: Bool
    public var isMarkedAsRead = false
    public var isInAddressBook = false
    public var hasTransparentOutputs = false
    
    public var rawID: Data? = nil
    
    // UI Colors
    public func balanceColor(_ colorScheme: ColorScheme) -> Color {
        status == .failed
        ? Design.Utility.ErrorRed._600.color(colorScheme)
        : (isSpending || isShieldingTransaction)
        ? Design.Utility.ErrorRed._600.color(colorScheme)
        : Asset.Colors.primary.color
    }

    public func titleColor(_ colorScheme: ColorScheme) -> Color {
        status == .failed
        ? Design.Utility.ErrorRed._600.color(colorScheme)
        : isPending
        ? Asset.Colors.shade47.color
        : Asset.Colors.primary.color
    }

    public var isUnread: Bool {
        // in case memos haven't been loaded yet
        // non-nil rawID represents unloaded memos state
        if rawID != nil && memoCount > 0 {
            return !isMarkedAsRead
        }
        
        // there must be memos
        guard let memos else { return false }
        
        // it must be a textual one
        var textMemoExists = false
        
        for memo in memos {
            if case .text = memo {
                if let memoText = memo.toString(), !memoText.isEmpty {
                    textMemoExists = true
                    break
                }
            }
        }

        if !textMemoExists {
            return false
        }
        
        // and it must be externally marked as read
        return !isMarkedAsRead
    }

    // UI Texts
    public var address: String {
        zAddress ?? ""
    }
    
    public var title: String {
        switch status {
        case .failed:
            // TODO: failed shielded is not covered!
            return isSentTransaction
            ? L10n.Transaction.failedSend
            : L10n.Transaction.failedReceive
        case .paid:
            return L10n.Transaction.sent
        case .received:
            return L10n.Transaction.received
        case .receiving:
            return L10n.Transaction.receiving
        case .sending:
            return L10n.Transaction.sending
        case .shielding:
            return L10n.Transaction.shieldingFunds
        case .shielded:
            return L10n.Transaction.shieldedFunds
        }
    }

    public var dateString: String? {
        guard minedHeight != nil else { return "" }
        guard let timestamp else { return nil }
        
        return Date(timeIntervalSince1970: timestamp).asHumanReadable()
    }

    // Helper flags
    public var isPending: Bool {
        switch status {
        case .failed:
            return false
        case .paid:
            return false
        case .received:
            return false
        case .receiving:
            return true
        case .sending:
            return true
        case .shielded:
            return false
        case .shielding:
            return true
        }
    }

    /// The purpose of this flag is to help understand if the transaction affected the wallet and a user paid a fee
    public var isSpending: Bool {
        switch status {
        case .paid, .sending:
            return true
        case .received, .receiving:
            return false
        case .shielded, .shielding:
            return false
        case .failed:
            return isSentTransaction
        }
    }

    // Values
    public var totalAmount: Zatoshi {
        Zatoshi(zecAmount.amount + (fee?.amount ?? 0))
    }

    public var textMemos: [String]? {
        guard let memos else { return nil }
        
        var res: [String] = []
        
        for memo in memos {
            if case .text = memo {
                guard let memoText = memo.toString(), !memoText.isEmpty else {
                    continue
                }
                
                res.append(memoText)
            }
        }
        
        return res.isEmpty ? nil : res
    }
    
    public init(
        errorMessage: String? = nil,
        expiryHeight: BlockHeight? = nil,
        memoCount: Int = 0,
        memos: [Memo]? = nil,
        minedHeight: BlockHeight? = nil,
        shielded: Bool = true,
        zAddress: String? = nil,
        fee: Zatoshi?,
        id: String,
        status: Status,
        timestamp: TimeInterval? = nil,
        zecAmount: Zatoshi,
        isSentTransaction: Bool = false,
        isShieldingTransaction: Bool = false,
        isTransparentRecipient: Bool = false,
        isAddressExpanded: Bool = false,
        isExpanded: Bool = false,
        isIdExpanded: Bool = false,
        isMarkedAsRead: Bool = false
    ) {
        self.errorMessage = errorMessage
        self.expiryHeight = expiryHeight
        self.memoCount = memoCount
        self.memos = memos
        self.minedHeight = minedHeight
        self.shielded = shielded
        self.zAddress = zAddress
        self.fee = fee
        self.id = id
        self.status = status
        self.timestamp = timestamp
        self.zecAmount = zecAmount
        self.isSentTransaction = isSentTransaction
        self.isShieldingTransaction = isShieldingTransaction
        self.isTransparentRecipient = isTransparentRecipient
        self.isAddressExpanded = isAddressExpanded
        self.isExpanded = isExpanded
        self.isIdExpanded = isIdExpanded
        self.isMarkedAsRead = isMarkedAsRead
    }
    
    public func confirmationsWith(_ latestMinedHeight: BlockHeight?) -> BlockHeight {
        guard let minedHeight, let latestMinedHeight, minedHeight > 0, latestMinedHeight > 0 else {
            return 0
        }
        
        return latestMinedHeight - minedHeight
    }
    
    public func transactionListHeight(_ mempoolHeight: BlockHeight) -> BlockHeight {
        var tlHeight = mempoolHeight
        
        if let minedHeight = minedHeight {
            tlHeight = minedHeight
        } else if let expiredHeight = expiryHeight, expiredHeight > 0 {
            tlHeight = expiredHeight
        }
        
        return tlHeight
    }
}

extension TransactionState {
    public init(
        transaction: ZcashTransaction.Overview,
        memos: [Memo]? = nil,
        hasTransparentOutputs: Bool = false,
        latestBlockHeight: BlockHeight
    ) {
        expiryHeight = transaction.expiryHeight
        minedHeight = transaction.minedHeight
        fee = transaction.fee
        id = transaction.rawID.toHexStringTxId()
        timestamp = transaction.blockTime
        isSentTransaction = transaction.isSentTransaction
        isShieldingTransaction = transaction.isShielding
        zecAmount = isSentTransaction ? Zatoshi(-transaction.value.amount) : transaction.value
        isTransparentRecipient = false
        isAddressExpanded = false
        isExpanded = false
        isIdExpanded = false
        self.hasTransparentOutputs = hasTransparentOutputs
        memoCount = transaction.memoCount
        self.memos = memos

        // TODO: [#1313] SDK improvements so a client doesn't need to determine if the transaction isPending
        // https://github.com/zcash/ZcashLightClientKit/issues/1313
        // The only reason why `latestBlockHeight` is provided here is to determine pending
        // state of the transaction. SDK knows the latestBlockHeight so ideally ZcashTransaction.Overview
        // already knows and provides isPending as a bool value.
        // Once SDK's #1313 is done, adopt the SDK and remove latestBlockHeight here.
        let isPending = transaction.isPending(currentHeight: latestBlockHeight)

        // failed check
        if let expiryHeight = transaction.expiryHeight, expiryHeight <= latestBlockHeight && minedHeight == nil {
            status = .failed
        } else if isShieldingTransaction {
            status = isPending ? .shielding : .shielded
        } else {
            switch (isSentTransaction, isPending) {
            case (true, true): status = .sending
            case (true, false): status = .paid
            case (false, true): status = .receiving
            case (false, false): status = .received
            }
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
    
    public static let mockedSent = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: BlockHeight(1),
        zAddress: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .paid,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_000_000),
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedReceived = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: BlockHeight(1),
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .received,
        timestamp: 1699292621,
        zecAmount: Zatoshi(25_000_000),
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedFailed = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: nil,
        zAddress: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .failed,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_108_700),
        isSentTransaction: true,
        isAddressExpanded: true,
        isExpanded: true,
        isIdExpanded: false
    )
    
    public static let mockedFailedReceive = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: nil,
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .failed,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_001_000),
        isSentTransaction: false,
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedSending = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: nil,
        zAddress: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .sending,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_000_000),
        isSentTransaction: true,
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedReceiving = TransactionState(
        memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
        minedHeight: nil,
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .receiving,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_000_000),
        isSentTransaction: false,
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedShielded = TransactionState(
        minedHeight: BlockHeight(1),
        zAddress: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .shielded,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_000_000),
        isShieldingTransaction: true,
        isAddressExpanded: false,
        isExpanded: false,
        isIdExpanded: false
    )
    
    public static let mockedShieldedExpanded = TransactionState(
        minedHeight: BlockHeight(1),
        zAddress: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
        fee: Zatoshi(10_000),
        id: "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja",
        status: .shielded,
        timestamp: 1699290621,
        zecAmount: Zatoshi(25_000_000),
        isShieldingTransaction: true,
        isAddressExpanded: false,
        isExpanded: true,
        isIdExpanded: false
    )
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
