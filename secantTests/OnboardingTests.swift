//
//  OnboardingTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 9/8/21.
//

import XCTest
import Combine
@testable import secant_testnet
class OnboardingTests: XCTestCase {
    var cancellables: [AnyCancellable] = []

    func testWhenThereIsASingleOnboardingStepItShouldNotShowStepper() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showStepper)
    }

    func testWhenThereIsASingleStepItShouldNotShowNextButton() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showNextButton)
    }

    func testWhenThereIsASingleStepItShouldNotShowPreviousButton() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showPreviousButton)
    }

    func testWhenThereAreManyStepsItShouldShowStepper() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertTrue(viewModel.showStepper)
    }

    func testWhenStepsArePendingRightNavItemShouldSaySkip() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertEqual(viewModel.showRightBarButton, OnboardingScreenViewModel.RightBarButton.skip)
    }

    func testWhenLastStepRightNavItemShouldSayClose() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)
        viewModel.next()
        XCTAssertEqual(viewModel.showRightBarButton, OnboardingScreenViewModel.RightBarButton.close)
    }

    func testWhenFirstStepLeftNavItemShouldNotShow() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showPreviousButton)
    }

    func testWhenThereIsAPriorStepLeftNavItemShouldShow() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)
        viewModel.next()
        XCTAssertTrue(viewModel.showPreviousButton)
    }

    func testWhenNextButtonIsTappedStepShouldIncrement() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        let previousStepNumber = viewModel.currentStep.stepNumber
        viewModel.next()
        let currentStepNumber = viewModel.currentStep.stepNumber

        XCTAssertEqual(abs(previousStepNumber - currentStepNumber), 1)
        XCTAssertTrue(previousStepNumber < currentStepNumber, "Step should be higher after incrementing it")
    }

    func testWhenBackButtonIsTappedStepShouldDecrement() {
        let stepProvider = OnboardingStepProviderBuilder()
            .add(.stepOne)
            .add(.stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        viewModel.next()
        let previousStepNumber = viewModel.currentStep.stepNumber
        viewModel.previous()
        let currentStepNumber = viewModel.currentStep.stepNumber

        XCTAssertEqual(abs(previousStepNumber - currentStepNumber), 1)
        XCTAssertTrue(previousStepNumber > currentStepNumber, "Step should be lower after decrementing it")
    }

    func testWhenNextButtonIsTappedTheFollowingStepIsPublished() throws {
        let stepOne = OnboardingStep.stepOne
        let stepTwo = OnboardingStep.stepTwo
        let expectation = XCTestExpectation(description: "next button should publish the following item")

        let stepProvider = OnboardingStepProviderBuilder()
            .add(stepOne)
            .add(stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        viewModel.$currentStep
            .dropFirst()
            .sink { step in
                expectation.fulfill()
                XCTAssertEqual(step, stepTwo)
            }
            .store(in: &cancellables)
        viewModel.next()
        wait(for: [expectation], timeout: 0.1)
    }

    func testWhenPreviousButtonIsTappedThePrecedingStepIsPublished() throws {
        let stepOne = OnboardingStep.stepOne
        let stepTwo = OnboardingStep.stepTwo
        let expectation = XCTestExpectation(description: "previous button should publish the preceding item")

        let stepProvider = OnboardingStepProviderBuilder()
            .add(stepOne)
            .add(stepTwo)
            .build()
        let viewModel = OnboardingScreenViewModel(services: stepProvider)
        viewModel.next()
        viewModel.$currentStep
            .dropFirst()
            .sink { step in
                expectation.fulfill()
                XCTAssertEqual(step, stepOne)
            }
            .store(in: &cancellables)
        viewModel.previous()
        wait(for: [expectation], timeout: 0.1)
    }
}
