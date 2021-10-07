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
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showStepper)
    }

    func testWhenThereIsASingleStepItShouldNotShowNextButton() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showNextButton)
    }

    func testWhenThereIsASingleStepItShouldNotShowPreviousButton() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showPreviousButton)
    }

    func testWhenThereAreManyStepsItShouldShowStepper() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertTrue(viewModel.showStepper)
    }

    func testWhenStepsArePendingRightNavItemShouldSaySkip() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertEqual(viewModel.showRightBarButton, OnboardingScreenViewModel.RightBarButton.skip)
    }

    func testWhenLastStepRightNavItemShouldSayClose() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ],
            startingAt: 1
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)
        
        XCTAssertEqual(viewModel.showRightBarButton, OnboardingScreenViewModel.RightBarButton.close)
    }

    func testWhenFirstStepLeftNavItemShouldNotShow() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertFalse(viewModel.showPreviousButton)
    }

    func testWhenThereIsAPriorStepLeftNavItemShouldShow() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ],
            startingAt: 1
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        XCTAssertTrue(viewModel.showPreviousButton)
    }

    func testWhenNextButtonIsTappedStepShouldIncrement() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ]
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)

        let previousStepNumber = viewModel.currentStep.stepNumber
        viewModel.next()
        let currentStepNumber = viewModel.currentStep.stepNumber

        XCTAssertEqual(abs(previousStepNumber - currentStepNumber), 1)
        XCTAssertTrue(previousStepNumber < currentStepNumber, "Step should be higher after incrementing it")
    }

    func testWhenBackButtonIsTappedStepShouldDecrement() {
        let stepProvider = OnboardingStepProvider(
            steps: [
                .stepZero,
                .stepOne
            ],
            startingAt: 1
        )
        let viewModel = OnboardingScreenViewModel(services: stepProvider)
        let previousStepNumber = viewModel.currentStep.stepNumber

        viewModel.previous()

        let currentStepNumber = viewModel.currentStep.stepNumber

        XCTAssertEqual(abs(previousStepNumber - currentStepNumber), 1)
        XCTAssertTrue(previousStepNumber > currentStepNumber, "Step should be lower after decrementing it")
    }

    func testWhenNextButtonIsTappedTheFollowingStepIsPublished() throws {
        let stepOne = OnboardingStep.stepZero
        let stepTwo = OnboardingStep.stepOne
        let expectation = XCTestExpectation(description: "next button should publish the following item")

        let stepProvider = OnboardingStepProvider(
            steps: [
                stepOne,
                stepTwo
            ]
        )
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
        let stepOne = OnboardingStep.stepZero
        let stepTwo = OnboardingStep.stepOne
        let expectation = XCTestExpectation(description: "previous button should publish the preceding item")

        let stepProvider = OnboardingStepProvider(
            steps: [
                stepOne,
                stepTwo
            ],
            startingAt: 1
        )

        let viewModel = OnboardingScreenViewModel(services: stepProvider)
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
