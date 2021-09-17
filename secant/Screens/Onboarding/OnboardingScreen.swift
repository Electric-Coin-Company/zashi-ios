//
//  OnboardingScreen.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 9/17/21.
//

import SwiftUI

protocol OnboardingScreenRouter: AnyObject {
    func onboardingDone()
}

struct OnboardingScreen: View {
    @ObservedObject var viewModel: OnboardingScreenViewModel

    @State var router: OnboardingScreenRouter?

    var body: some View {
        VStack(
            alignment: .center,
            spacing: 30
        ) {
            Image(systemName: viewModel.currentStep.imageName)
                .resizable()
                .frame(
                    width: 100,
                    height: 100,
                    alignment: .center
                )

            if let title = viewModel.currentStep.title {
                Text(title)
                    .font(.title)
            }

            Text(viewModel.currentStep.blurb)
            Spacer()
            Stepper(
                currentStep: viewModel.currentStep.stepNumber,
                totalSteps: viewModel.totalSteps
            )
        }
        .animation(.easeIn, value: viewModel.currentStep)
        .toolbar {
            ItemsToolbar(
                next: viewModel.next,
                previous: viewModel.previous,
                skip: skip,
                close: skip,
                nextButton: viewModel.showRightBarButton,
                showPrevious: viewModel.showPreviousButton
            )
        }
        .padding()
    }

    func skip() {
        router?.onboardingDone()
    }

    func close() {
        router?.onboardingDone()
    }
}

struct ItemsToolbar: ToolbarContent {
    let next: () -> Void
    let previous: () -> Void
    let skip: () -> Void
    let close: () -> Void

    let nextButton: OnboardingScreenViewModel.RightBarButton
    let showPrevious: Bool
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if showPrevious {
                Button(
                    "Previous",
                    action: previous
                )
            }
        }

        ToolbarItemGroup(placement: .navigationBarTrailing) {
            switch nextButton {
            case .close:
                Button(
                    "Close",
                    action: close
                )
            case .skip:
                Button(
                    "Next",
                    action: next
                )
                Button(
                    "Skip",
                    action: skip
                )
            case .none:
                EmptyView()
            }
        }
    }
}

struct OnboardingScreenPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingScreen(
                viewModel: OnboardingScreenViewModel(
                    services: OnboardingStepProviderBuilder()
                        .add(.stepOne)
                        .add(.stepTwo)
                        .build()
                )
            )
        }
    }
}
