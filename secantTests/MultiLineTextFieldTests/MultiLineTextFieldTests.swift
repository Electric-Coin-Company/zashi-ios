//
//  MultiLineTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 01.08.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class MultiLineTextFieldTests: XCTestCase {
    func testIsCharLimited() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(charLimit: 1),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertTrue(
                state.isCharLimited,
                "Multiline TextFiler tests: `testIsCharLimited` is expected to be true but it is \(state.isCharLimited)"
            )
        }
    }

    func testIsNotCharLimited() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertFalse(
                state.isCharLimited,
                "Multiline TextFiler tests: `testIsNotCharLimited` is expected to be false but it is \(state.isCharLimited)"
            )
        }
    }

    func testTextLength() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertEqual(
                4,
                state.textLength,
                "Multiline TextFiler tests: `testTextLength` is expected to be 4 but it is \(state.textLength)"
            )
        }
    }
    
    func testIsValid_CharLimit() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(charLimit: 4),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertTrue(
                state.isValid,
                "Multiline TextFiler tests: `testIsValid_CharLimit` is expected to be true but it is \(state.isValid)"
            )
        }
    }

    func testIsValid_NoCharLimit() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertTrue(
                state.isValid,
                "Multiline TextFiler tests: `testIsValid_NoCharLimit` is expected to be true but it is \(state.isValid)"
            )
        }
    }
    
    func testIsInvalid() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(charLimit: 3),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertFalse(
                state.isValid,
                "Multiline TextFiler tests: `testIsInvalid` is expected to be false but it is \(state.isValid)"
            )
        }
    }
    
    func testCharLimitText_NoCharLimit() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertEqual(
                "",
                state.charLimitText,
                "Multiline TextFiler tests: `testCharLimitText_NoCharLimit` is expected to be \"\" but it is \(state.charLimitText)"
            )
        }
    }
    
    func testCharLimitText_CharLimit_LessCharacters() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(charLimit: 5),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertEqual(
                "4/5",
                state.charLimitText,
                "Multiline TextFiler tests: `testCharLimitText_CharLimit_LessCharacters` is expected to be \"4/5\" but it is \(state.charLimitText)"
            )
        }
    }
    
    func testCharLimitText_CharLimit_Exceeded() throws {
        let store = TestStore(
            initialState: MultiLineTextFieldReducer.State(charLimit: 3),
            reducer: MultiLineTextFieldReducer()
        )
        
        store.send(.binding(.set(\.$text, "test"))) { state in
            state.text = "test"
            XCTAssertEqual(
                "char limit exceeded 4/3",
                state.charLimitText,
                "Multiline TextFiler tests: `testCharLimitText_CharLimit_Exceeded` is expected to be \"4/5\" but it is \(state.charLimitText)"
            )
        }
    }
}
