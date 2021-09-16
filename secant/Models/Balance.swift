//
//  Balance.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import Foundation

/**
Funds Expressed in Zatoshis
*/
protocol Funds {
    /**
    Confirmed, spendable funds
    */
    var confirmed: Int64 { get }

    /**
    Unconfirmed, not yet spendable funds.
    */
    var unconfirmed: Int64 { get }

    /**
    Represents a null value of Funds with Zero confirmed and Zero unconfirmed funds.
    */
    static var noFunds: Funds { get }
}

/**
Wallet Balance that condenses transpant, Sapling and Orchard funds
*/
protocol WalletBalance {
    /**
    Transparent funds. This is the sum of the UTXOs of the user found at a given time
    */
    var transaparent: Funds { get }

    /**
    Funds on the Sapling shielded pool for a given user.
    */
    var sapling: Funds { get }

    /**
    Funds on the Orchard shielded pool for a given user.
    */
    var orchard: Funds { get }

    /**
    The sum of all confirmed funds, transparent, sapling and orchard funds (calculated)
    */
    var totalAvailableBalance: Int64 { get }

    /**
    The sum of all unconfirmed funds: transparent, sapling, and orchard funds (calculated
    */
    var totalUnconfirmedBalance: Int64 { get }

    /**
    The sum of all funds confirmed and unconfirmed of all pools (transparent, sapling and orchard).
    */
    var totalBalance: Int64 { get }

    /**
    Represents a the value of Zero funds.
    */
    static var nullBalance: WalletBalance { get }
}

extension WalletBalance {
    static var nullBalance: WalletBalance {
        Balance(
            transaparent: ZcashFunds.noFunds,
            sapling: ZcashFunds.noFunds,
            orchard: ZcashFunds.noFunds
        )
    }

    var totalAvailableBalance: Int64 {
        transaparent.confirmed + sapling.confirmed + orchard.confirmed
    }

    var totalUnconfirmedBalance: Int64 {
        transaparent.unconfirmed + sapling.unconfirmed + orchard.unconfirmed
    }

    var totalBalance: Int64 {
        totalAvailableBalance + totalUnconfirmedBalance
    }
}

/**
Concrete Wallet Balance.
*/
struct Balance: WalletBalance {
    var transaparent: Funds
    var sapling: Funds
    var orchard: Funds
}

struct ZcashFunds: Funds {
    static var noFunds: Funds {
        ZcashFunds(confirmed: 0, unconfirmed: 0)
    }

    var confirmed: Int64
    var unconfirmed: Int64
}
