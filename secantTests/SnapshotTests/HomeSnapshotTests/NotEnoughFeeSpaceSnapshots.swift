//
//  NotEnoughFeeSpaceViewSnapshots.swift
//  secantTests
//
//  Created by Michal Fousek on 28.09.2022.
//

import Foundation

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class NotEnoughFeeSpaceSnapshots: XCTestCase {
    func testNotEnoughFreeSpaceSnapshot() throws {
        addAttachments(NotEnoughFreeSpaceView(viewStore: ViewStore(HomeStore.placeholder)))
    }
}
