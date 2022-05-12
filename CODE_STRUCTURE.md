# Code Consistency & Project Structure
In our project the syntax check is done by [swiftlint]. However, the architecture we use is the [TCA] (The Composable Architecture) and therefore we need to follow some basic principles and rules to hold structure of the files as well as project. This document describes rules for the code as well as project files/folders structure we agreed on. We encourage you to kindly follow these principles.

# Structure of the TCA Store file
For the Store and View as well as folder name we focus on features. So the <feature name> is the bare bone of the TCA code, uppercased!

## Store file
The TCA consists of 5 blocks (state, action, environment, reducer and store). The TCA code lives in the <feature name>Store file. We defined the following order of sections in this file:
1. Typealiases for the Reducer, Store and a ViewStore.
2. State
3. Action
4. Environment - always present even when no dependencies are defined = never use Void
5. Reducer holding private `Hashable` Ids, always use `static let default` reducer. Try to avoid `default: return .none` for the actions, we want the switch exhaustiveness check. 
6. Store
7. Viewstore
8. Placeholders

Any extension needed is defined under the relevant section except placeholders, those are separated at the very end of the file. Example: 

```swift
// MARK: - State

struct <feature name>State: Equatable { }

extension <feature name>State {
    // anything but placeholder
}

// MARK: - Action
// ...
```

## Structure of Store & View files

Use the appropriate name for a feature you want to build. The <feature name> must be bare bone of any TCA definition including the folder encapsulating the swift file(s). Example:

```swift
// Project structure
// Folder <feature name> woth following files:

// <feature name>Store.swift
struct <feature name>State: Equatable { }
enum <feature name>Action: Equatable { }
struct <feature name>Environment

// <feature name>View.swift
struct <feature name>: View {
    let store: <feature name>Store
    
    var body: some View {
        WithViewStore(store) { viewStore in EmptyView() }
    }
}

struct <feature name>_Previews: PreviewProvider {
    static var previews: some View {
    <feature name>(store: .placeholder)
    }
}
```

Do not omit Previews!

## Navigation
Navigation is done using routes. Such mechanism consists of Route definition + state and Route action to update the state.
```swift
struct <feature>State
enum Route {
    case <route name>
}
var route: Route?
}

enum <feature>Action {
    case updateRoute(<feature>State.Route?)
}
```

## XCode Template
We created a TCA template that automatically prepares the TCA files and code with the rules defined in this document. You can download it [here].

To add them to Xcode, follow the next steps:
1. open Finder
2. press cmd + shift + G
3. paste `/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates`
4. copy paste the TCA.xctemplate to the `MultiPlatform/Source/`

The template is customizable and consists of 3 sections:

1. TCA Store text field. This is essentially the <feature name>
2. View selector of either
a. Empty (= TCA file with no navigation included)
b. Navigation (= TCA file with the navigation)
3. Reducer selector of either
a. Standalone (= only simple `default` reducer is created)
b. Combined (= the `default` reducer is created so it combines more reducers)
4. Checkbox which allows you to create also a View file if requested.

## Project Structure
The project follows the structure detailed below:
```
Models
    <model>.swift
Wrappers
    Wrapped<dependency name>.swift
Utils
    <util>.swift
Dependencies
    <dependency name>.swift
Features
    <feature name>
        <feature name>Store.swift
        <feature name>View.swift
        Views (optional)
UI Components
    <component name>
        <component name>.swift
Resources
    Generated (by swiftgen)
    Fonts
    <any other resources go here>
```

## Models
Here are the models used in the project, usually data containers shared across several places.
Examples:
- Transaction struct - holding the data for the transaction
- StoredWallet struct - holding the secured and sensitive data for the wallet

## Wrappers
Here are the wrapped modules either from the SDK, iOS itself or wallet custom modules. Purpose of wrappers is to provide `live` implementation and other versions used testing purposes, usually one of the following:
- `mock` - mocked data
- `throwing` - throwing errors
- `test` - specific setup for particular tests

Examples of the wrappers:
- SDK: Mnemonic, DerivingTool, SDKSynchronizer, ...
- iOS: FileManager, UserDefaults, NotificationCenter, ...
- wallet: DatabaseFiles, WalletStorage, ...

## Utils
Here are the utilities used in the project. Usually helpers or extensions of the build in types. 
Examples:
- helpers: navigation links, bindings, view modifiers, ...
- types: `String` extensions for the conversions, `UInt`/`Int64` extensions to handle balance computations, etc.```

## Dependencies
Modules used as dependencies by the reducers are located here. Some dependencies are already living in the SDK and only a wrapper is implemented (stored in the wrappers folder) for it. Sometimes the dependency is implemented in a way that it doesn't need to be wrapped (typically it uses some wrapped helper). In that case, the `live` vs. `mocked` static instances are implemented directly within the same file as the dependency.

## Features vs. UI Components
We distinguish between smaller building blocks used in the composed complex UIs vs. screens and flows - understand features. Essentially we talk about two topics:
1. Features: typically views representing entire screeens, the whole flows, complex UIs and business logic that are usually not shared or used many times.
2. UI Components: smaller building blocks typically used across the application and features, like custom controls (buttons, input fields) or visual elements. Even when used just once, the nature of a UI component is to be reused so it's not forming standalone feature.

Examples:
- features: Send Flow, Onboarding Flow, Settings Screen, Scan Screen, Profile Screen, ...
- UI Components: buttons, chips, button styles, view modifiers, drawer, custom textfields, shapes, ...

 When implementing something new, just ask yourself "Am I building something that can be shared and used several times or am I building a standalone feature?".

In case of a *flow feature* the following structure is used:
```swift
<feature name>Flow
    <feature name>FlowStore.swift
    <feature name>FlowView.swift
    Views
        <some 1st>View.swift
        <some 2nd>View.swift
        <some nth>View.swift
```

## Resources
All project resources should be placed in this folder. Images, fonts, generated files (by swiftgen for example), sounds, assets, string files, ...

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[TCA]: <https://github.com/pointfreeco/swift-composable-architecture>
[swiftlint]: <https://github.com/zcash/secant-ios-wallet#swiftlint>
[here]:  <https://github.com/zcash/secant-ios-wallet/tree/main/xctemplates/TCA.xctemplate>
