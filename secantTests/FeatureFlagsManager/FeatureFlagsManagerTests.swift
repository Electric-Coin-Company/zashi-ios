//
//  FeatureFlagsManagerTests.swift
//  secantTests
//
//  Created by Michal Fousek on 23.02.2023.
//

import XCTest
@testable import secant_testnet

class FeatureFlagsManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()

        UserDefaultsFeatureFlagsStorage().clearAll()
    }

    func testLoadFlagsFromProvider() async {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))

        let provider = FeatureFlagsManagerConfigurationProviderMock() {
            return FeatureFlagsConfiguration(flags: [.testFlag1: true, .testFlag2: false])
        }

        let manager = FeatureFlagsManager(configurationProvider: provider, cache: UserDefaultsFeatureFlagsStorage())
        let configuration = await manager.load()

        XCTAssertTrue(configuration.isEnabled(.testFlag1))
        XCTAssertFalse(configuration.isEnabled(.testFlag2))
    }

    func testLoadFlagsFromCache() async {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))

        let provider = FeatureFlagsManagerConfigurationProviderMock() { throw NSError(domain: "whatever", code: 21) }
        let cache = FeatureFlagsManagerCacheMock(cachedFlags: [.testFlag1: false, .testFlag2: true])

        let manager = FeatureFlagsManager(configurationProvider: provider, cache: cache)
        let configuration = await manager.load()

        XCTAssertFalse(configuration.isEnabled(.testFlag1))
        XCTAssertTrue(configuration.isEnabled(.testFlag2))
    }

    func testLoadDefaultFlags() async {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))

        let provider = FeatureFlagsManagerConfigurationProviderMock() { throw NSError(domain: "whatever", code: 21) }
        let cache = FeatureFlagsManagerCacheMock(cachedFlags: [:])

        let manager = FeatureFlagsManager(configurationProvider: provider, cache: cache)
        let configuration = await manager.load()

        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))
    }

    func testAllTheFlagsAreAlwaysReturned() async {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))

        let provider = FeatureFlagsManagerConfigurationProviderMock() {
            return FeatureFlagsConfiguration(flags: [.testFlag1: true])
        }

        let manager = FeatureFlagsManager(configurationProvider: provider, cache: UserDefaultsFeatureFlagsStorage())
        let configuration = await manager.load()

        XCTAssertTrue(configuration.isEnabled(.testFlag1))
        XCTAssertFalse(configuration.isEnabled(.testFlag2))
    }

    func testProvidedFlagsAreCached() async {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag1))
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.testFlag2))

        let provider = FeatureFlagsManagerConfigurationProviderMock() {
            return FeatureFlagsConfiguration(flags: [.testFlag1: true, .testFlag2: false])
        }
        let cache: FeatureFlagsManagerCache = UserDefaultsFeatureFlagsManagerCache()

        let manager = FeatureFlagsManager(configurationProvider: provider, cache: cache)
        _ = await manager.load()

        guard let cachedConfiguration = await cache.load() else {
            return XCTFail("No cached configuration.")
        }

        XCTAssertTrue(cachedConfiguration.isEnabled(.testFlag1))
        XCTAssertFalse(cachedConfiguration.isEnabled(.testFlag2))
    }
}

struct FeatureFlagsManagerConfigurationProviderMock: FeatureFlagsConfigurationProvider {
    let provider: () async throws -> FeatureFlagsConfiguration

    func load() async throws -> FeatureFlagsConfiguration {
        return try await provider()
    }
}

class FeatureFlagsManagerCacheMock: FeatureFlagsManagerCache {
    var cachedFlags: FeatureFlagsConfiguration.RawFlags = [:]

    init(cachedFlags: FeatureFlagsConfiguration.RawFlags) {
        self.cachedFlags = cachedFlags
    }

    func load() async -> FeatureFlagsConfiguration? {
        guard !cachedFlags.isEmpty else { return nil }
        return FeatureFlagsConfiguration(flags: cachedFlags)
    }

    func store(_ configuration: FeatureFlagsConfiguration) async {
        cachedFlags = configuration.flags
    }
}

extension UserDefaultsFeatureFlagsStorage {
    func clearAll() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: Constants.cacheKey)
        ud.removeObject(forKey: Constants.providerKey)
        ud.synchronize()
    }
}
