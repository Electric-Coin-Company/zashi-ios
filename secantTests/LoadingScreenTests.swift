//
//  AppRouterNavigationTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 9/2/21.
//

import XCTest
@testable import secant_testnet
import Foundation
import Combine
class LoadingScreenTests: XCTestCase {
    var cancellables: [AnyCancellable] = []
    
    // MARK: LoadingScreenViewModel Tests
    
    func testCredentialsFoundIsPublishedWhenCredentialsArePresent() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            true
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)
        // swiftlint:disable:next line_length
        let testExpectation = XCTestExpectation(description: "LoadingViewModel Publishes .credentialsFound when credentials are present and there's no failure")
        let expected = LoadingScreenViewModel.LoadingResult.credentialsFound
        
        loadingViewModel.$loadingResult
            .dropFirst()
            .sink { loadingResult in
                testExpectation.fulfill()
                
                XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
                switch loadingResult {
                case .success(let result):
                    XCTAssertEqual(result, expected)
                case .failure(let error):
                    XCTFail("found error \(error.localizedDescription)")
                case .none:
                    XCTFail("found None when expected a value")
                }
            }
            .store(in: &cancellables)
        loadingViewModel.loadAsync()
        wait(for: [testExpectation], timeout: 0.1)
    }

    func testNewWalletLoadingResultPublishedWhenNoCredentialsFound() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            false
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)
        let testExpectation = XCTestExpectation(
            description: "LoadingViewModel Publishes .newWallet when no credentials are present and there's no failure"
        )
        let expected = LoadingScreenViewModel.LoadingResult.newWallet
        
        loadingViewModel.$loadingResult
            .dropFirst()
            .sink { loadingResult in
                testExpectation.fulfill()
                
                XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
                switch loadingResult {
                case .success(let result):
                    XCTAssertEqual(result, expected)
                case .failure(let error):
                    XCTFail("found error \(error.localizedDescription)")
                case .none:
                    XCTFail("found None when expected a value")
                }
            }
            .store(in: &cancellables)
        loadingViewModel.loadAsync()
        wait(for: [testExpectation], timeout: 0.1)
    }
    
    func testFailureIsPublishedWhenWalletFailsToInitialize() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            throw KeyStoringError.alreadyImported
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)
        let testExpectation = XCTestExpectation(description: "LoadingViewModel Publishes .failure when there's a failure")
        
        loadingViewModel.$loadingResult
            .dropFirst()
            .sink { loadingResult in
                testExpectation.fulfill()
                
                XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
                switch loadingResult {
                case .success(let result):
                    XCTFail("found result: \(result) but expected a failure")
                case .failure:
                    XCTAssertTrue(true) // fails when expected
                case .none:
                    XCTFail("found None when expected a failure")
                }
            }
            .store(in: &cancellables)
        loadingViewModel.loadAsync()
        wait(for: [testExpectation], timeout: 0.1)
    }

    func testNewWalletLoadingResultReturnedWhenCredentialsAreNotPresent() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            false
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)
        
        let expected = LoadingScreenViewModel.LoadingResult.newWallet
        let result = loadingViewModel.load()
        
        XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
        switch result {
        case .failure(let error):
            XCTFail("found error \(error.localizedDescription)")
        case .success(let res):
            XCTAssertEqual(expected, res)
        }
    }
    
    func testCredentialsFoundReturnedWhenCredentialsArePresent() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            true
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)
                
        let expected = LoadingScreenViewModel.LoadingResult.credentialsFound
        let result = loadingViewModel.load()
        
        XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
        switch result {
        case .failure(let error):
            XCTFail("found error \(error.localizedDescription)")
        case .success(let res):
            XCTAssertEqual(expected, res)
        }
    }
    
    func testLoadReturnsErrorWhenLoadingFails() throws {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: {
            throw KeyStoringError.uninitializedWallet
        })
        mockServices.keyStorage = stub
        let loadingViewModel = LoadingScreenViewModel(services: mockServices)

        let result = loadingViewModel.load()
        XCTAssertTrue(stub.isAreKeysPresentFunctionCalled)
        switch result {
        case .failure:
            XCTAssertTrue(true)
        case .success(let res):
            XCTFail("case succeeded when testing failure - result: \(res)")
        }
    }
    
    // MARK: LoadingScreen View Tests
    
    func testProceedToHomeIsCalledWhenCredentialsAreFound() throws {
        let loadingViewModel = LoadingScreenViewModelHelper.loadingViewModelWith {
            true
        }

        let spyRouter = LoadingScreenRouterSpy(fulfillment: {
        })
        
        loadingViewModel.callRouter(spyRouter, with: loadingViewModel.load())
        XCTAssertTrue(spyRouter.proceedToHomeCalled)
    }
    
    func testProceedToWelcomeIsCalledWhenCredentialsAreNotFound() throws {
        let loadingViewModel = LoadingScreenViewModelHelper.loadingViewModelWith {
            false
        }

        let spyRouter = LoadingScreenRouterSpy(fulfillment: {
        })
        
        loadingViewModel.callRouter(spyRouter, with: loadingViewModel.load())
        XCTAssertTrue(spyRouter.proceedToWelcomeCalled)
    }
    
    func testFailWithErrorIsCalledWhenKeyStoringFails() throws {
        let loadingViewModel = LoadingScreenViewModelHelper.loadingViewModelWith {
            throw KeyStoringError.alreadyImported
        }

        let spyRouter = LoadingScreenRouterSpy(fulfillment: {
        })
        
        loadingViewModel.callRouter(spyRouter, with: loadingViewModel.load())
        XCTAssertTrue(spyRouter.failWithErrorCalled)
    }
}

class LoadingScreenRouterSpy: LoadingScreenRouter {
    var fulfillmentBlock: () -> Void
    var proceedToHomeCalled = false
    var failWithErrorCalled = false
    var proceedToWelcomeCalled = false

    init(fulfillment: @escaping () -> Void) {
        self.fulfillmentBlock = fulfillment
    }

    func proceedToHome() {
        proceedToHomeCalled = true
        fulfillmentBlock()
    }
    
    func failWithError() {
        failWithErrorCalled = true
        fulfillmentBlock()
    }
    
    func proceedToWelcome() {
        proceedToWelcomeCalled = true
        fulfillmentBlock()
    }
}

enum LoadingScreenViewModelHelper {
    static func loadingViewModelWith(keysPresentStubBlock: @escaping () throws -> Bool) -> LoadingScreenViewModel {
        let mockServices = MockServices()
        let stub = KeysPresentStub(returnBlock: keysPresentStubBlock)
        mockServices.keyStorage = stub
        return LoadingScreenViewModel(services: mockServices)
    }
}
