//
//  Near1ClickTests.swift
//  zodlTests
//
//  Batch 4 — dependency logic. Covers Near1Click.amountMessageResolution swap-error parsing
//  (Dependencies/SwapAndPay/sources/Near1Click.swift).
//

import Testing
import Foundation
@testable import zodl_internal

@Suite struct Near1ClickTests {
    @Test func unknownErrorWhenNoMessageKey() {
        #expect(throws: SwapAndPayClient.EndpointError.message("Unknown error")) {
            try Near1Click.amountMessageResolution(exactInput: false, isSwapToZec: false, toAsset: asset(), jsonObject: [:])
        }
    }

    @Test func passesThroughUnrecognizedMessage() {
        #expect(throws: SwapAndPayClient.EndpointError.message("some random error")) {
            try Near1Click.amountMessageResolution(exactInput: false, isSwapToZec: false, toAsset: asset(), jsonObject: ["message": "some random error"])
        }
    }

    @Test func failedToGetQuoteMapsToLocalizedMessage() {
        #expect(throws: SwapAndPayClient.EndpointError.message(String(localizable: .swapQuoteUnavailableSwap))) {
            try Near1Click.amountMessageResolution(exactInput: true, isSwapToZec: false, toAsset: asset(), jsonObject: ["message": "Failed to get quote"])
        }
        #expect(throws: SwapAndPayClient.EndpointError.message(String(localizable: .swapQuoteUnavailable))) {
            try Near1Click.amountMessageResolution(exactInput: false, isSwapToZec: false, toAsset: asset(), jsonObject: ["message": "Failed to get quote"])
        }
    }

    @Test func rescalesAmountTooLowToZec() {
        do {
            try Near1Click.amountMessageResolution(
                exactInput: true,
                isSwapToZec: false,
                toAsset: asset(decimals: 6),
                jsonObject: ["message": "Amount is too low for bridge, try at least 100000000"]
            )
            Issue.record("expected a throw")
        } catch let SwapAndPayClient.EndpointError.message(msg) {
            #expect(msg.hasPrefix("Amount is too low for bridge, try at least"))
            #expect(msg.contains("ZEC"))
        } catch {
            Issue.record("unexpected error: \(error)")
        }
    }

    @Test func rescalesAmountTooLowToToken() {
        do {
            try Near1Click.amountMessageResolution(
                exactInput: false,
                isSwapToZec: false,
                toAsset: asset(token: "USDC", decimals: 6),
                jsonObject: ["message": "Amount is too low for bridge, try at least 1000000"]
            )
            Issue.record("expected a throw")
        } catch let SwapAndPayClient.EndpointError.message(msg) {
            #expect(msg.contains("USDC"))
        } catch {
            Issue.record("unexpected error: \(error)")
        }
    }

    // MARK: - swapStatus(from:isSwapToZec:) 1Click status mapping (PRO-325)

    @Test func failedMapsToFailedInBothDirections() {
        #expect(Near1Click.swapStatus(from: SwapConstants.failed, isSwapToZec: false) == .failed)
        #expect(Near1Click.swapStatus(from: SwapConstants.failed, isSwapToZec: true) == .failed)
    }

    @Test func processingMapsToProcessingInBothDirections() {
        #expect(Near1Click.swapStatus(from: SwapConstants.processing, isSwapToZec: false) == .processing)
        #expect(Near1Click.swapStatus(from: SwapConstants.processing, isSwapToZec: true) == .processing)
    }

    @Test func pendingDepositKeepsDirectionSpecificMapping() {
        #expect(Near1Click.swapStatus(from: SwapConstants.pendingDeposit, isSwapToZec: false) == .pending)
        #expect(Near1Click.swapStatus(from: SwapConstants.pendingDeposit, isSwapToZec: true) == .pendingDeposit)
    }

    @Test func sharedTerminalAndPartialStatusesMap() {
        for isSwapToZec in [false, true] {
            #expect(Near1Click.swapStatus(from: SwapConstants.refunded, isSwapToZec: isSwapToZec) == .refunded)
            #expect(Near1Click.swapStatus(from: SwapConstants.success, isSwapToZec: isSwapToZec) == .success)
            #expect(Near1Click.swapStatus(from: SwapConstants.incompleteDeposit, isSwapToZec: isSwapToZec) == .incompleteDeposit)
        }
    }

    @Test func unknownStatusFallsBackToPending() {
        #expect(Near1Click.swapStatus(from: "KNOWN_DEPOSIT_TX", isSwapToZec: false) == .pending)
        #expect(Near1Click.swapStatus(from: "KNOWN_DEPOSIT_TX", isSwapToZec: true) == .pending)
    }

    // MARK: - curated(_:) source-level allow-list (MOB-1472)

    @Test func curatedKeepsSupportedAndDropsRest() {
        let kept = Near1Click.curated([
            swapAsset(assetId: "nep141:btc.omft.near"),                                     // supported
            swapAsset(assetId: "nep141:eth.omft.near"),                                     // supported
            swapAsset(assetId: "nep245:v2_1.omni.hot.tg:137_qiStmoQJDQPTebaPjgx5VBxZv6L"),  // pol.usdc — supported
            // SHIB@eth is offered by 1Click but deliberately not curated. (This used to be
            // DOGE@doge, which is curated as of the ADA/ALEO/GRAM/DOGE/POL/EURe/GNO addition.)
            swapAsset(assetId: "nep141:eth-0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce.omft.near")
        ])
        let ids = kept.map(\.assetId)
        #expect(kept.count == 3)
        #expect(ids.contains("nep141:btc.omft.near"))
        #expect(ids.contains("nep141:eth.omft.near"))
        #expect(ids.contains("nep245:v2_1.omni.hot.tg:137_qiStmoQJDQPTebaPjgx5VBxZv6L"))
        #expect(!ids.contains("nep141:eth-0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce.omft.near"))
    }

    @Test func curatedKeepsNativeZecAndTokenZecAndDropsOtherWrappedZec() {
        let kept = Near1Click.curated([
            // native ZEC — the swap-to-ZEC representation, must survive
            swapAsset(assetId: Near1Click.Constants.nearZecAssetId, token: "ZEC", chain: "zec"),
            // ZEC on Solana — supported as a swap target, must survive
            swapAsset(assetId: "1cs_v1:sol:spl:A7bdiYdS5GjqGFtxf17ppRHtDKPkkRqbKtR27dxvQXaS", token: "ZEC", chain: "sol"),
            // ZEC on NEAR — supported as a swap target, must survive
            swapAsset(assetId: "1cs_v1:near:nep141:zec.omft.near", token: "ZEC", chain: "near"),
            // wrapped ZEC on another chain — same symbol, different assetId, must drop
            swapAsset(assetId: "1cs_v1:starknet:erc20:0x05ce53b9b68fb8e9ecab9283a96d97948914733fd6ed8d9a53a276a419497841", token: "ZEC", chain: "starknet")
        ])
        let ids = kept.map(\.assetId)
        #expect(kept.count == 3)
        #expect(ids.contains(Near1Click.Constants.nearZecAssetId))
        #expect(ids.contains("1cs_v1:sol:spl:A7bdiYdS5GjqGFtxf17ppRHtDKPkkRqbKtR27dxvQXaS"))
        #expect(ids.contains("1cs_v1:near:nep141:zec.omft.near"))
    }

    @Test func curatedPreservesEverySupportedAsset() {
        let all = Near1Click.Constants.supportedAssetIds.map { swapAsset(assetId: $0) }
        let kept = Near1Click.curated(all)
        #expect(Set(kept.map(\.assetId)) == Near1Click.Constants.supportedAssetIds)
    }

    @Test func curatedEmptyStaysEmpty() {
        #expect(Near1Click.curated([]).isEmpty)
    }

    // Pins the assets added on request (ADA, ALEO, USDCx, GRAM, DOGE, POL, EURe, GNO) by their
    // 1Click `assetId`, so a bad edit to the allow-list drops them loudly instead of silently.
    @Test func curatedIncludesTheRequestedAssets() {
        let expected = [
            "nep141:cardano.omft.near",                                                  // ADA@cardano
            "nep141:aleo.omft.near",                                                     // ALEO@aleo
            "nep141:aleo-usdcx.omft.near",                                               // USDCx@aleo
            "nep245:v2_1.omni.hot.tg:1117_",                                             // GRAM@ton
            "nep141:doge.omft.near",                                                     // DOGE@doge
            "nep245:v2_1.omni.hot.tg:137_11111111111111111111",                          // POL@pol
            "nep245:v2_1.omni.hot.tg:137_qiStmoQJDQPTebaPjgx5VBxZv6L",                   // USDC@pol
            "nep141:gnosis-0x420ca0f9b9b604ce0fd9c18ef134c705e5fa3430.omft.near",        // EURe@gnosis
            "nep141:gnosis-0x9c58bacc331c9aa871afd802db6379a98e80cedb.omft.near"         // GNO@gnosis
        ]
        let kept = Near1Click.curated(expected.map { swapAsset(assetId: $0) }).map(\.assetId)
        #expect(Set(kept) == Set(expected))
    }

    // The new chains must also reach the address book's offline fallback picker.
    @Test func curatedChainsCoverTheNewChains() {
        let chains = Set(SwapAsset.curatedChains().map(\.chain))
        for chain in ["cardano", "aleo", "ton", "doge", "gnosis", "pol"] {
            #expect(chains.contains(chain), "\(chain) should be a curated contact chain")
        }
        #expect(!chains.contains("zec"))
    }

    // Display names for the newly curated tokens; the rest fall back to the ticker.
    @Test func tokenNamesForTheNewTokens() {
        #expect(swapAsset(assetId: "", token: "ADA").tokenName == "Cardano")
        #expect(swapAsset(assetId: "", token: "ALEO").tokenName == "Aleo")
        #expect(swapAsset(assetId: "", token: "DOGE").tokenName == "Dogecoin")
        #expect(swapAsset(assetId: "", token: "EURe").tokenName == "Monerium EUR")
        #expect(swapAsset(assetId: "", token: "GNO").tokenName == "Gnosis")
        #expect(swapAsset(assetId: "", token: "GRAM").tokenName == "Gram")
        #expect(swapAsset(assetId: "", token: "USDCx").tokenName == "USDCx")
    }

    private func asset(token: String = "ETH", decimals: Int = 18) -> SwapAsset {
        SwapAsset(provider: "near", chain: "eth", token: token, assetId: "x", usdPrice: 0, decimals: decimals)
    }

    private func swapAsset(assetId: String, token: String = "TKN", chain: String = "eth") -> SwapAsset {
        SwapAsset(provider: "near", chain: chain, token: token, assetId: assetId, usdPrice: 1, decimals: 6)
    }
}
