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
import UIKit

/// This is a quick fix for Flexa changing the balances of the account from an expected value to 0.
var accountHashInMemoryUUID = UUID()

enum Constants {
    static let zecHash = "bip122:00040fe8ec8471911baa1db1266ea15d"
    static let zecId = "\(Constants.zecHash)/slip44:133"

    static func assetAccountHash() -> String {
        let uuid = accountHashInMemoryUUID
        let uuidString = uuid.uuidString
        let data = Data(uuidString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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
        let latestSpendableAvailableBalance = CurrentValueSubject<Decimal?, Never>(nil)
        let isPrepared = CurrentValueSubject<Bool, Never>(false)

        return .init(
            prepare: {
                FlexaHandlerClient.prepare()
                isPrepared.value = true
            },
            open: {
                accountHashInMemoryUUID = UUID()
                
                if !isPrepared.value {
                    FlexaHandlerClient.prepare()
                    isPrepared.value = true
                }
                
                onTransactionRequest.send(nil)
                Flexa.sections([.spend])
                    .assetAccounts(
                        FlexaHandlerClient.accounts(latestSpendableBalance.value, zecAvailableAmount: latestSpendableAvailableBalance.value)
                    )
                    .selectedAsset(Constants.assetAccountHash(), Constants.zecId)
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
            clearTransactionRequest: {
                onTransactionRequest.send(nil)
            },
            transactionSent: {
                onTransactionRequest.send(nil)
                Flexa.transactionSent(commerceSessionId: $0, signature: $1)
            },
            updateBalance: {
                latestSpendableBalance.value = $0.decimalValue.decimalValue
                latestSpendableAvailableBalance.value = $1?.decimalValue.decimalValue
                Flexa.updateAssetAccounts(
                    FlexaHandlerClient.accounts(latestSpendableBalance.value, zecAvailableAmount: latestSpendableAvailableBalance.value)
                )
            },
            flexaAlert: { title, message in
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: L10n.General.ok, style: .cancel))
                    UIViewController.showOnTop(alert)
                }
            },
            signOut: {
                Flexa.buildIdentity().build().close()
            }
        )
    }
}

private extension FlexaHandlerClient {
    static func accounts(_ zecAmount: Decimal = 0, zecAvailableAmount: Decimal? = nil) -> [FXAssetAccount] {
        [
            FXAssetAccount(
                assetAccountHash: Constants.assetAccountHash(),
                displayName: "",
                custodyModel: .local,
                availableAssets: [
                    FXAvailableAsset(
                        assetId: Constants.zecId,
                        symbol: "ZEC",
                        balance: zecAmount,
                        balanceAvailable: zecAvailableAmount,
                        icon: UIImage(named: "zcashZecLogo") ?? UIImage()
                    )
                ]
            )
        ]
    }
    
    static func prepare() {
        guard let flexaPublishableKey = PartnerKeys.flexaPublishableKey else {
            return
        }
        Flexa.initialize(
            FXClient(
                publishableKey: flexaPublishableKey,
                assetAccounts: FlexaHandlerClient.accounts(),
                theme: .default
            )
        )
    }
}
