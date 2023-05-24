# secant-ios-wallet

This wallet is a Dogfooding effort towards Zcash Halo Arc / NU5 efforts.

# Motivation
Dogfooding - _transitive verb_ - is the practice of an organization using its own product. This app was created to help us learn.

Please take note: the wallet is not an official product by ECC, but rather a tool for learning about our libraries that it is built on. This means that we do not have robust infrastructure or user support for this application. We open sourced it as a resource to make wallet development easier for the Zcash ecosystem.

# Disclaimers
There are some known areas for improvement:

- This app is mainly intended for learning and improving the related libraries that it uses. There may be bugs.
- Traffic analysis, like in other cryptocurrency wallets, can leak some privacy of the user.
- The wallet requires a trust in the server to display accurate transaction information. 

See the [Wallet App Threat Model](https://zcash.readthedocs.io/en/latest/rtd_pages/wallet_threat_model.html)
for more information about the security and privacy limitations of the wallet.

If you'd like to sign up to help us test, reach out on discord and let us know! We're always happy to get feedback!

# Description

iOS wallet using the Zcash iOS SDK that is maintained by core developers.

This a reference wallet for the following set of features:
- z2z transactions w/ encrypted memos
- reply-to formatted memos
- z2t transactions
- transparent receive-only
- autoshielding on threshold from receive only t-address

note: z means sapling shielded addresses.

# Installation of Swiftgen & Swiftlint on Apple Silicon chip

## Swiftgen
Install it using homebrew
```
$ brew install swiftgen
```
and create a symbolic link
```
ln -s /opt/homebrew/bin/swiftgen /usr/local/bin
```
## Swiftlint
The project is setup to work with `0.50.3` version. We recommend to install it directly using [the official 0.50.3 package](https://github.com/realm/SwiftLint/releases/download/0.50.3/SwiftLint.pkg). If you follow this step there is no symbolic link needed.

In case you already have swiftlint 0.50.3 ready on your machine and installed via homebrew, create a symbolic link
```
ln -s /opt/homebrew/bin/swiftlint /usr/local/bin
```

# Contributing

Contributions are very much welcomed! Please read our [Contributing Guidelines](/CONTRIBUTING.md) and [Code of Conduct](/CONDUCT.md). Our backlog has many Issues tagged with the `good first issue` label. Please fork the repo and make a pull request for us to review.

Secant Wallet uses [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftGen](https://github.com/SwiftGen/SwiftGen) to conform to our coding guidelines for source code and generate accessors for assets. Please install these locally when contributing to the project, they are run automatically when you build.
  
# Reporting an issue

If you wish to report a security issue, please follow our [Responsible Disclosure guidelines](https://github.com/zcash/ZcashLightClientKit/blob/master/responsible_disclosure.md).

 For other kind of inquiries, feel welcome to open an Issue if you encounter a bug or would like to request a feature.

 # License

 MIT
