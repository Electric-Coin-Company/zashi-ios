# Zashi IOS Wallet

This is the official home of the Zashi Zcash wallet for Wallet, a no-frills
Zcash mobile wallet leveraging the [Zcash Swift SDK](https://github.com/Electric-Coin-Company/zcash-swift-wallet-sdk).

# Beta Testing

The Zashi IOS wallet is currently in closed beta testing, and will be publicly
available from the Apple Store when testing is complete.

If you'd like to be added to the waitlist to become a Zashi beta tester,
please [sign up here](https://docs.google.com/forms/d/e/1FAIpQLSeQpykeMF8QcxnX5W8ya0pXIf5YPRRpUXD7H1gvbzv_WyASPw/viewform).

# Reporting an issue

If you'd like to report a technical issue or feature request for the IOS
Wallet, please file a GitHub issue [here](https://github.com/Electric-Coin-Company/zashi-ios/issues/new/choose).

For feature requests and issues related to the Zashi user interface that are
not IOS-specific, please file a GitHub issue [here](https://github.com/Electric-Coin-Company/zashi/issues/new/choose).

If you wish to report a security issue, please follow our
[Responsible Disclosure guidelines](https://github.com/Electric-Coin-Company/zashi/blob/master/responsible_disclosure.md).
See the [Wallet App Threat Model](https://github.com/Electric-Coin-Company/zashi/blob/master/wallet_threat_model.md)
for more information about the security and privacy limitations of the wallet.

General Zcash questions and/or support requests and are best directed to either:
 * [Zcash Forum](https://forum.zcashcommunity.com/)
 * [Discord Community](https://discord.io/zcash-community)

# Contributing

Contributions are very much welcomed! Please read our [Contributing Guidelines](/CONTRIBUTING.md) 
and [Code of Conduct](/CONDUCT.md). Our backlog has many Issues tagged with the
`good first issue` label. Please fork the repo and make a pull request for us
to review.

Secant Wallet uses [SwiftLint](https://github.com/realm/SwiftLint) and 
[SwiftGen](https://github.com/SwiftGen/SwiftGen) to conform to our coding
guidelines for source code and generate accessors for assets. Please install
these locally when contributing to the project, they are run automatically when
you build.

## Installation of Swiftgen & Swiftlint on Apple Silicon-based hardware

### Swiftgen

Install it using homebrew
```
$ brew install swiftgen
```
and create a symbolic link
```
ln -s /opt/homebrew/bin/swiftgen /usr/local/bin
```

### Swiftlint

The project is setup to work with `0.50.3` version. We recommend to install it
directly using [the official 0.50.3 package](https://github.com/realm/SwiftLint/releases/download/0.50.3/SwiftLint.pkg).
If you follow this step there is no symbolic link needed.

In case you already have swiftlint 0.50.3 ready on your machine and installed via homebrew, create a symbolic link
```
ln -s /opt/homebrew/bin/swiftlint /usr/local/bin
```
