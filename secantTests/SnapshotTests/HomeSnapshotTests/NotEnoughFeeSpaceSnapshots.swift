//
//  NotEnoughFeeSpaceViewSnapshots.swift
//  secantTests
//
//  Created by Michal Fousek on 28.09.2022.
//

import Foundation

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Home
@testable import secant_testnet

class NotEnoughFeeSpaceSnapshots: XCTestCase {
    func testNotEnoughFreeSpaceSnapshot() throws {
        addAttachments(NotEnoughFreeSpaceView(viewStore: ViewStore(HomeStore.placeholder)))
    }
}
