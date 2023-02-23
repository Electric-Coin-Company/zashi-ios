//
//  WalletConfigProviderTests.swift
//  secantTests
//
//  Created by Michal Fousek on 23.02.2023.
//

import XCTest
@testable import secant_testnet

class WalletConfigProviderTests: XCTestCase {
    override func setUp() {
        super.setUp()

        UserDefaultsWalletConfigStorage().clearAll()
    }

    func testLoadFlagsFromProvider() async {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))

        let provider = WalletConfigSourceProviderMock() {
            return WalletConfig(flags: [.testFlag1: true, .testFlag2: false])
        }

        let manager = WalletConfigProvider(configSourceProvider: provider, cache: UserDefaultsWalletConfigStorage())
        let configuration = await manager.load()

        XCTAssertTrue(configuration.isEnabled(.testFlag1))
        XCTAssertFalse(configuration.isEnabled(.testFlag2))
    }

    func testLoadFlagsFromCache() async {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))

        let provider = WalletConfigSourceProviderMock() { throw NSError(domain: "whatever", code: 21) }
        let cache = WalletConfigProviderCacheMock(cachedFlags: [.testFlag1: false, .testFlag2: true])

        let manager = WalletConfigProvider(configSourceProvider: provider, cache: cache)
        let configuration = await manager.load()

        XCTAssertFalse(configuration.isEnabled(.testFlag1))
        XCTAssertTrue(configuration.isEnabled(.testFlag2))
    }

    func testLoadDefaultFlags() async {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))

        let provider = WalletConfigSourceProviderMock() { throw NSError(domain: "whatever", code: 21) }
        let cache = WalletConfigProviderCacheMock(cachedFlags: [:])

        let manager = WalletConfigProvider(configSourceProvider: provider, cache: cache)
        let configuration = await manager.load()

        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))
    }

    func testAllTheFlagsAreAlwaysReturned() async {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))

        let provider = WalletConfigSourceProviderMock() {
            return WalletConfig(flags: [.testFlag1: true])
        }

        let manager = WalletConfigProvider(configSourceProvider: provider, cache: UserDefaultsWalletConfigStorage())
        let configuration = await manager.load()

        XCTAssertTrue(configuration.isEnabled(.testFlag1))
        XCTAssertFalse(configuration.isEnabled(.testFlag2))
    }

    func testProvidedFlagsAreCached() async {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag1))
        XCTAssertFalse(WalletConfig.default.isEnabled(.testFlag2))

        let provider = WalletConfigSourceProviderMock() {
            return WalletConfig(flags: [.testFlag1: true, .testFlag2: false])
        }
        let cache: WalletConfigProviderCache = UserDefaultsWalletConfigProviderCache()

        let manager = WalletConfigProvider(configSourceProvider: provider, cache: cache)
        _ = await manager.load()

        guard let cachedConfiguration = await cache.load() else {
            return XCTFail("No cached configuration.")
        }

        XCTAssertTrue(cachedConfiguration.isEnabled(.testFlag1))
        XCTAssertFalse(cachedConfiguration.isEnabled(.testFlag2))
    }
}

struct WalletConfigSourceProviderMock: WalletConfigSourceProvider {
    let provider: () async throws -> WalletConfig

    func load() async throws -> WalletConfig {
        return try await provider()
    }
}

class WalletConfigProviderCacheMock: WalletConfigProviderCache {
    var cachedFlags: WalletConfig.RawFlags = [:]

    init(cachedFlags: WalletConfig.RawFlags) {
        self.cachedFlags = cachedFlags
    }

    func load() async -> WalletConfig? {
        guard !cachedFlags.isEmpty else { return nil }
        return WalletConfig(flags: cachedFlags)
    }

    func store(_ configuration: WalletConfig) async {
        cachedFlags = configuration.flags
    }
}

extension UserDefaultsWalletConfigStorage {
    func clearAll() {
        let userdef = UserDefaults.standard
        userdef.removeObject(forKey: Constants.cacheKey)
        userdef.removeObject(forKey: Constants.providerKey)
        userdef.synchronize()
    }
}
