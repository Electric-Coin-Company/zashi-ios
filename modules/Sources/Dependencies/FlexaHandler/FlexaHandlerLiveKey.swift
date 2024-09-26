//
//  FlexaHandlerLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-09-2024
//

import Foundation
import ComposableArchitecture
import Combine
import UserDefaults
import Flexa
import ZcashLightClientKit
import PartnerKeys
import CryptoKit
import Generated

let accountId = Constants.accountId()

enum Constants {
    static let zecHash = "bip122:00040fe8ec8471911baa1db1266ea15d"
    static let zecId = "\(Constants.zecHash)/slip44:133"

    static func accountId() -> String {
        @Shared(.appStorage(.flexaAccountId)) var flexaAccountId = ""

        if flexaAccountId.isEmpty {
            let uuid = UUID()
            let uuidString = uuid.uuidString
            let data = Data(uuidString.utf8)
            let hash = SHA256.hash(data: data)
            
            flexaAccountId = hash.compactMap { String(format: "%02x", $0) }.joined()
        }

        return flexaAccountId
    }
}

public struct FlexaTransaction: Equatable {
    public let amount: Zatoshi
    public let address: String
    public let commerceSessionId: String
    
    public init(amount: Zatoshi, address: String, commerceSessionId: String) {
        self.amount = amount
        self.address = address
        self.commerceSessionId = commerceSessionId
    }
}

extension FlexaHandlerClient: DependencyKey {
    public static var liveValue: Self {
        let onTransactionRequest = CurrentValueSubject<Result<FXTransaction, any Error>?, Never>(nil)
        let latestSpendableBalance = CurrentValueSubject<Decimal, Never>(0)

        return .init(
            prepare: {
                guard let flexaPublishableKey = PartnerKeys.flexaPublishableKey else {
                    return
                }
                Flexa.initialize(
                    FXClient(
                        publishableKey: flexaPublishableKey,
                        appAccounts: FlexaHandlerClient.accounts(),
                        theme: .default
                    )
                )
            },
            open: {
                print("__LD open flexa with \(latestSpendableBalance.value)")
                Flexa.sections([.spend])
                    .appAccounts(FlexaHandlerClient.accounts(latestSpendableBalance.value))
                    .selectedAsset(accountId, Constants.zecId)
                    .onTransactionRequest({
                        onTransactionRequest.send($0)
                    })
                    .open()
            },
            onTransactionRequest: {
                onTransactionRequest
                    .compactMap { $0 }
                    .map { result in
                        switch result {
                        case .success(let transaction):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.locale = Locale(identifier: "en_US")

                            // format the amount
                            guard let amount = formatter.number(from: transaction.amount) else {
                                return nil
                            }
                            
                            let zatoshi = amount.doubleValue * 100_000_000
                            let amountZatoshi = Zatoshi(Int64(zatoshi))

                            // check the zecHash
                            guard transaction.destinationAddress.contains(Constants.zecHash) else {
                                return nil
                            }
                            
                            // parse the address
                            guard let parsedAddress = transaction.destinationAddress.split(separator: ":").last else {
                                return nil
                            }

                            return FlexaTransaction(
                                amount: amountZatoshi,
                                address: String(parsedAddress),
                                commerceSessionId: transaction.commerceSessionId
                            )
                        case .failure:
                            return nil
                        }
                    }
                    .eraseToAnyPublisher()
            },
            transactionSent: {
                Flexa.transactionSent(commerceSessionId: $0, signature: $1)
            },
            updateBalance: {
                latestSpendableBalance.value = $0.decimalValue.decimalValue
                print("__LD updateAppAccounts \(latestSpendableBalance.value)")
                Flexa.updateAppAccounts(FlexaHandlerClient.accounts(latestSpendableBalance.value))
            }
        )
    }
}

private extension FlexaHandlerClient {
    static func accounts(_ zecAmount: Decimal = 0) -> [FXAppAccount] {
        [
            FXAppAccount(
                accountId: accountId,
                displayName: "",
                custodyModel: .local,
                availableAssets: [
                    FXAvailableAsset(
                        assetId: Constants.zecId,
                        symbol: "ZEC",
                        balance: zecAmount
                    )
                ]
            )
        ]
    }
}
