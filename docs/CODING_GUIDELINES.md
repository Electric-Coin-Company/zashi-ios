# Coding Guidelines

Your contributions are very welcome, however we'd like you to please follow our coding guidelines. We've created them to be able to have a base structure that enable our maintainer to evaluate and review all contributions equally.

Some rules are being enforced by SwiftLint. Please look at [SwiftLint guidelines](../blob/master/SWIFTLINT.md) for more information.

# Creating new files
When creating new files, please use the provided templates when applicable. You can find them in the [xctemplates folder](../blob/master/xctemplates).

# Type definition structure

When defining new type or modificating an existing one, please follow the convention below:

````
Type
-nested types
-static properties
-constants
-variables
-computed properties
-init methods
-instance methods

# extension for static functions (optional)
# private extension for private functions (optional)
# extension for Type conformances to individual protocols (not optional)

(# denotes the usage of a mandatory pragma mark)
````

# Use of vertical whitespace
We encourage developers to make strategic use of vertical whitespace. This means that it should be used to the devs' advantage not only to improve readability, but also to convey meaning to a code block

## Whitespace in SwiftUI body builders

*Not preferred:* body function builders with no vertical spacing

````swift
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
````

*Preferred: vertical whitespace is used to convey meaning by separating different view declarations

````Swift
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
            // notice the space
            if let title = viewModel.currentStep.title {
                Text(title)
                    .font(.title)
            }
            // notice the space
            Text(viewModel.currentStep.blurb)
            // notice the space
            Spacer()
            // notice the space
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
````