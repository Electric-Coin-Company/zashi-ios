// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// %@ %@
  public static func balance(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "balance", String(describing: p1), String(describing: p2), fallback: "%@ %@")
  }
  /// QR Code for %@
  public static func qrCodeFor(_ p1: Any) -> String {
    return L10n.tr("Localizable", "qrCodeFor", String(describing: p1), fallback: "QR Code for %@")
  }
  public enum AddressDetails {
    /// Sapling Address
    public static let sa = L10n.tr("Localizable", "addressDetails.sa", fallback: "Sapling Address")
    /// Transparent Address
    public static let ta = L10n.tr("Localizable", "addressDetails.ta", fallback: "Transparent Address")
    /// Unified Address
    public static let ua = L10n.tr("Localizable", "addressDetails.ua", fallback: "Unified Address")
    public enum Error {
      /// could not extract sapling receiver from UA
      public static let cantExtractSaplingAddress = L10n.tr("Localizable", "addressDetails.error.cantExtractSaplingAddress", fallback: "could not extract sapling receiver from UA")
      /// could not extract transparent receiver from UA
      public static let cantExtractTransparentAddress = L10n.tr("Localizable", "addressDetails.error.cantExtractTransparentAddress", fallback: "could not extract transparent receiver from UA")
      /// could not extract UA
      public static let cantExtractUnifiedAddress = L10n.tr("Localizable", "addressDetails.error.cantExtractUnifiedAddress", fallback: "could not extract UA")
    }
  }
  public enum Balance {
    /// %@ %@ Available
    public static func available(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "balance.available", String(describing: p1), String(describing: p2), fallback: "%@ %@ Available")
    }
  }
  public enum BalanceBreakdown {
    /// Shielding Threshold: %@ %@
    public static func autoShieldingThreshold(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "balanceBreakdown.autoShieldingThreshold", String(describing: p1), String(describing: p2), fallback: "Shielding Threshold: %@ %@")
    }
    /// Block: %@
    public static func blockId(_ p1: Any) -> String {
      return L10n.tr("Localizable", "balanceBreakdown.blockId", String(describing: p1), fallback: "Block: %@")
    }
    /// SHIELDED %@ (SPENDABLE)
    public static func shieldedZec(_ p1: Any) -> String {
      return L10n.tr("Localizable", "balanceBreakdown.shieldedZec", String(describing: p1), fallback: "SHIELDED %@ (SPENDABLE)")
    }
    /// Shield funds
    public static let shieldFunds = L10n.tr("Localizable", "balanceBreakdown.shieldFunds", fallback: "Shield funds")
    /// Shielding funds
    public static let shieldingFunds = L10n.tr("Localizable", "balanceBreakdown.shieldingFunds", fallback: "Shielding funds")
    /// TOTAL BALANCE
    public static let totalSpendableBalance = L10n.tr("Localizable", "balanceBreakdown.totalSpendableBalance", fallback: "TOTAL BALANCE")
    /// TRANSPARENT BALANCE
    public static let transparentBalance = L10n.tr("Localizable", "balanceBreakdown.transparentBalance", fallback: "TRANSPARENT BALANCE")
    public enum Alert {
      public enum ShieldFunds {
        public enum Failure {
          /// Error: %@ (code: %@)
          public static func message(_ p1: Any, _ p2: Any) -> String {
            return L10n.tr("Localizable", "balanceBreakdown.alert.shieldFunds.failure.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
          }
          /// Failed to shield funds
          public static let title = L10n.tr("Localizable", "balanceBreakdown.alert.shieldFunds.failure.title", fallback: "Failed to shield funds")
        }
        public enum Success {
          /// Shielding transaction created
          public static let message = L10n.tr("Localizable", "balanceBreakdown.alert.shieldFunds.success.message", fallback: "Shielding transaction created")
          /// Done
          public static let title = L10n.tr("Localizable", "balanceBreakdown.alert.shieldFunds.success.title", fallback: "Done")
        }
      }
    }
  }
  public enum Error {
    /// possible roll back
    public static let rollBack = L10n.tr("Localizable", "error.rollBack", fallback: "possible roll back")
  }
  public enum ExportLogs {
    public enum Alert {
      public enum Failed {
        /// Error: %@ (code: %@)
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "exportLogs.alert.failed.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
        }
        /// Error when exporting logs
        public static let title = L10n.tr("Localizable", "exportLogs.alert.failed.title", fallback: "Error when exporting logs")
      }
    }
  }
  public enum Field {
    public enum Multiline {
      /// char limit exceeded
      public static let charLimitExceeded = L10n.tr("Localizable", "field.multiline.charLimitExceeded", fallback: "char limit exceeded")
    }
    public enum TransactionAddress {
      /// To:
      public static let to = L10n.tr("Localizable", "field.transactionAddress.to", fallback: "To:")
      /// Valid Zcash Address
      public static let validZcashAddress = L10n.tr("Localizable", "field.transactionAddress.validZcashAddress", fallback: "Valid Zcash Address")
    }
    public enum TransactionAmount {
      /// Amount:
      public static let amount = L10n.tr("Localizable", "field.transactionAmount.amount", fallback: "Amount:")
      /// %@ Amount
      public static func zecAmount(_ p1: Any) -> String {
        return L10n.tr("Localizable", "field.transactionAmount.zecAmount", String(describing: p1), fallback: "%@ Amount")
      }
    }
  }
  public enum General {
    /// Back
    public static let back = L10n.tr("Localizable", "general.back", fallback: "Back")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "general.cancel", fallback: "Cancel")
    /// Clear
    public static let clear = L10n.tr("Localizable", "general.clear", fallback: "Clear")
    /// Close
    public static let close = L10n.tr("Localizable", "general.close", fallback: "Close")
    /// date not available
    public static let dateNotAvailable = L10n.tr("Localizable", "general.dateNotAvailable", fallback: "date not available")
    /// Max
    public static let max = L10n.tr("Localizable", "general.max", fallback: "Max")
    /// Next
    public static let next = L10n.tr("Localizable", "general.next", fallback: "Next")
    /// No
    public static let no = L10n.tr("Localizable", "general.no", fallback: "No")
    /// Ok
    public static let ok = L10n.tr("Localizable", "general.ok", fallback: "Ok")
    /// Send
    public static let send = L10n.tr("Localizable", "general.send", fallback: "Send")
    /// Skip
    public static let skip = L10n.tr("Localizable", "general.skip", fallback: "Skip")
    /// Success
    public static let success = L10n.tr("Localizable", "general.success", fallback: "Success")
    /// Unknown
    public static let unknown = L10n.tr("Localizable", "general.unknown", fallback: "Unknown")
    /// Yes
    public static let yes = L10n.tr("Localizable", "general.yes", fallback: "Yes")
  }
  public enum Home {
    /// Receive %@
    public static func receiveZec(_ p1: Any) -> String {
      return L10n.tr("Localizable", "home.receiveZec", String(describing: p1), fallback: "Receive %@")
    }
    /// Send %@
    public static func sendZec(_ p1: Any) -> String {
      return L10n.tr("Localizable", "home.sendZec", String(describing: p1), fallback: "Send %@")
    }
    /// Secant Wallet
    public static let title = L10n.tr("Localizable", "home.title", fallback: "Secant Wallet")
    /// See transaction history
    public static let transactionHistory = L10n.tr("Localizable", "home.transactionHistory", fallback: "See transaction history")
    public enum SyncFailed {
      /// Dismiss
      public static let dismiss = L10n.tr("Localizable", "home.syncFailed.dismiss", fallback: "Dismiss")
      /// Retry
      public static let retry = L10n.tr("Localizable", "home.syncFailed.retry", fallback: "Retry")
      /// Sync failed!
      public static let title = L10n.tr("Localizable", "home.syncFailed.title", fallback: "Sync failed!")
    }
  }
  public enum ImportWallet {
    /// Enter your secret backup seed phrase.
    public static let description = L10n.tr("Localizable", "importWallet.description", fallback: "Enter your secret backup seed phrase.")
    /// Wallet Import
    public static let title = L10n.tr("Localizable", "importWallet.title", fallback: "Wallet Import")
    public enum Alert {
      public enum Failed {
        /// Error: %@ (code: %@)
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "importWallet.alert.failed.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
        }
        /// Failed to restore wallet
        public static let title = L10n.tr("Localizable", "importWallet.alert.failed.title", fallback: "Failed to restore wallet")
      }
      public enum Success {
        /// The wallet has been successfully recovered.
        public static let message = L10n.tr("Localizable", "importWallet.alert.success.message", fallback: "The wallet has been successfully recovered.")
        /// Success
        public static let title = L10n.tr("Localizable", "importWallet.alert.success.title", fallback: "Success")
      }
    }
    public enum Birthday {
      /// Do you know the wallet's creation date? This will allow a faster sync. If you don't know the wallet's birthday, don't worry!
      public static let description = L10n.tr("Localizable", "importWallet.birthday.description", fallback: "Do you know the wallet's creation date? This will allow a faster sync. If you don't know the wallet's birthday, don't worry!")
      /// Enter birthday height
      public static let placeholder = L10n.tr("Localizable", "importWallet.birthday.placeholder", fallback: "Enter birthday height")
    }
    public enum Button {
      /// Import a private or viewing key
      public static let importPrivateKey = L10n.tr("Localizable", "importWallet.button.importPrivateKey", fallback: "Import a private or viewing key")
      /// Restore wallet
      public static let restoreWallet = L10n.tr("Localizable", "importWallet.button.restoreWallet", fallback: "Restore wallet")
    }
    public enum Seed {
      /// VALID SEED PHRASE
      public static let valid = L10n.tr("Localizable", "importWallet.seed.valid", fallback: "VALID SEED PHRASE")
    }
  }
  public enum LocalAuthentication {
    /// The Following content requires authentication.
    public static let reason = L10n.tr("Localizable", "localAuthentication.reason", fallback: "The Following content requires authentication.")
  }
  public enum Nefs {
    /// Not enough space on disk to do synchronisation!
    public static let message = L10n.tr("Localizable", "nefs.message", fallback: "Not enough space on disk to do synchronisation!")
  }
  public enum Onboarding {
    public enum Button {
      /// Import an Existing Wallet
      public static let importWallet = L10n.tr("Localizable", "onboarding.button.importWallet", fallback: "Import an Existing Wallet")
      /// Create New Wallet
      public static let newWallet = L10n.tr("Localizable", "onboarding.button.newWallet", fallback: "Create New Wallet")
    }
    public enum Step1 {
      /// As a privacy focused wallet, we shield by default. Your wallet uses the shielded address for sending and moves transparent funds to that address automatically.
      /// 
      /// In other words, the 'privacy-please' sign is on the knob.
      public static let description = L10n.tr("Localizable", "onboarding.step1.description", fallback: "As a privacy focused wallet, we shield by default. Your wallet uses the shielded address for sending and moves transparent funds to that address automatically.\n\nIn other words, the 'privacy-please' sign is on the knob.")
      /// Welcome!
      public static let title = L10n.tr("Localizable", "onboarding.step1.title", fallback: "Welcome!")
    }
    public enum Step2 {
      /// You now have a unified address that includes and up-to-date shielded address for legacy systems.
      /// 
      /// This makes your wallet friendlier, and gives you and address that you won't have to upgrade again.
      public static let description = L10n.tr("Localizable", "onboarding.step2.description", fallback: "You now have a unified address that includes and up-to-date shielded address for legacy systems.\n\nThis makes your wallet friendlier, and gives you and address that you won't have to upgrade again.")
      /// Unified Addresses
      public static let title = L10n.tr("Localizable", "onboarding.step2.title", fallback: "Unified Addresses")
    }
    public enum Step3 {
      /// Due to Zcash's increased popularity, we are optimizing our syncing schemes to be faster and more efficient!
      /// 
      /// The future is fast!
      public static let description = L10n.tr("Localizable", "onboarding.step3.description", fallback: "Due to Zcash's increased popularity, we are optimizing our syncing schemes to be faster and more efficient!\n\nThe future is fast!")
      /// And so much more...
      public static let title = L10n.tr("Localizable", "onboarding.step3.title", fallback: "And so much more...")
    }
    public enum Step4 {
      /// Choose between creating a new wallet and importing and existing Secret Recovery Phrase
      public static let description = L10n.tr("Localizable", "onboarding.step4.description", fallback: "Choose between creating a new wallet and importing and existing Secret Recovery Phrase")
      /// Let's get started
      public static let title = L10n.tr("Localizable", "onboarding.step4.title", fallback: "Let's get started")
    }
  }
  public enum PlainOnboarding {
    /// We need to create a new wallet or restore an existing one. Select your path:
    public static let caption = L10n.tr("Localizable", "plainOnboarding.caption", fallback: "We need to create a new wallet or restore an existing one. Select your path:")
    /// It's time to setup your Secant, powered by Zcash, no-frills wallet.
    public static let title = L10n.tr("Localizable", "plainOnboarding.title", fallback: "It's time to setup your Secant, powered by Zcash, no-frills wallet.")
    public enum Button {
      /// Create a new Wallet
      public static let createNewWallet = L10n.tr("Localizable", "plainOnboarding.button.createNewWallet", fallback: "Create a new Wallet")
      /// Restore an existing wallet
      public static let restoreWallet = L10n.tr("Localizable", "plainOnboarding.button.restoreWallet", fallback: "Restore an existing wallet")
    }
  }
  public enum ReceiveZec {
    /// Your Address
    public static let yourAddress = L10n.tr("Localizable", "receiveZec.yourAddress", fallback: "Your Address")
    public enum Error {
      /// could not extract UA
      public static let cantExtractUnifiedAddress = L10n.tr("Localizable", "receiveZec.error.cantExtractUnifiedAddress", fallback: "could not extract UA")
    }
  }
  public enum RecoveryPhraseBackupValidation {
    /// Drag the words below to match your backed-up copy.
    public static let description = L10n.tr("Localizable", "recoveryPhraseBackupValidation.description", fallback: "Drag the words below to match your backed-up copy.")
    /// Your placed words did not match your secret recovery phrase
    public static let failedResult = L10n.tr("Localizable", "recoveryPhraseBackupValidation.failedResult", fallback: "Your placed words did not match your secret recovery phrase")
    /// Congratulations! You validated your secret recovery phrase.
    public static let successResult = L10n.tr("Localizable", "recoveryPhraseBackupValidation.successResult", fallback: "Congratulations! You validated your secret recovery phrase.")
    /// Verify Your Backup
    public static let title = L10n.tr("Localizable", "recoveryPhraseBackupValidation.title", fallback: "Verify Your Backup")
  }
  public enum RecoveryPhraseDisplay {
    /// The following 24 words represent your funds and the security used to protect them. Back them up now!
    public static let description = L10n.tr("Localizable", "recoveryPhraseDisplay.description", fallback: "The following 24 words represent your funds and the security used to protect them. Back them up now!")
    /// Oops no words
    public static let noWords = L10n.tr("Localizable", "recoveryPhraseDisplay.noWords", fallback: "Oops no words")
    /// Your Secret Recovery Phrase
    public static let title = L10n.tr("Localizable", "recoveryPhraseDisplay.title", fallback: "Your Secret Recovery Phrase")
    public enum Button {
      /// Copy To Buffer
      public static let copyToBuffer = L10n.tr("Localizable", "recoveryPhraseDisplay.button.copyToBuffer", fallback: "Copy To Buffer")
      /// I wrote it down!
      public static let wroteItDown = L10n.tr("Localizable", "recoveryPhraseDisplay.button.wroteItDown", fallback: "I wrote it down!")
    }
  }
  public enum RecoveryPhraseTestPreamble {
    /// It is important to understand that you are in charge here. Great, right? YOU get to be the bank!
    public static let paragraph1 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph1", fallback: "It is important to understand that you are in charge here. Great, right? YOU get to be the bank!")
    /// But it also means that YOU are the customer, and you need to be self-reliant.
    public static let paragraph2 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph2", fallback: "But it also means that YOU are the customer, and you need to be self-reliant.")
    /// So how do you recover funds that you've hidden on a completely decentralized and private block-chain?
    public static let paragraph3 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph3", fallback: "So how do you recover funds that you've hidden on a completely decentralized and private block-chain?")
    /// First things first
    public static let title = L10n.tr("Localizable", "recoveryPhraseTestPreamble.title", fallback: "First things first")
    public enum Button {
      /// By understanding and preparing
      public static let goNext = L10n.tr("Localizable", "recoveryPhraseTestPreamble.button.goNext", fallback: "By understanding and preparing")
    }
  }
  public enum Root {
    public enum Debug {
      /// Feature flags
      public static let featureFlags = L10n.tr("Localizable", "root.debug.featureFlags", fallback: "Feature flags")
      /// Startup
      public static let navigationTitle = L10n.tr("Localizable", "root.debug.navigationTitle", fallback: "Startup")
      /// Debug options
      public static let title = L10n.tr("Localizable", "root.debug.title", fallback: "Debug options")
      public enum Alert {
        public enum Rewind {
          public enum CantStartSync {
            /// Error: %@ (code: %@)
            public static func message(_ p1: Any, _ p2: Any) -> String {
              return L10n.tr("Localizable", "root.debug.alert.rewind.cantStartSync.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
            }
            /// Can't start sync process after rewind
            public static let title = L10n.tr("Localizable", "root.debug.alert.rewind.cantStartSync.title", fallback: "Can't start sync process after rewind")
          }
          public enum Failed {
            /// Error: %@ (code: %@)
            public static func message(_ p1: Any, _ p2: Any) -> String {
              return L10n.tr("Localizable", "root.debug.alert.rewind.failed.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
            }
            /// Rewind failed
            public static let title = L10n.tr("Localizable", "root.debug.alert.rewind.failed.title", fallback: "Rewind failed")
          }
        }
      }
      public enum Dialog {
        public enum Rescan {
          /// Select the rescan you want
          public static let message = L10n.tr("Localizable", "root.debug.dialog.rescan.message", fallback: "Select the rescan you want")
          /// Rescan
          public static let title = L10n.tr("Localizable", "root.debug.dialog.rescan.title", fallback: "Rescan")
          public enum Option {
            /// Full rescan
            public static let full = L10n.tr("Localizable", "root.debug.dialog.rescan.option.full", fallback: "Full rescan")
            /// Quick rescan
            public static let quick = L10n.tr("Localizable", "root.debug.dialog.rescan.option.quick", fallback: "Quick rescan")
          }
        }
      }
      public enum Option {
        /// Rate the app
        public static let appReview = L10n.tr("Localizable", "root.debug.option.appReview", fallback: "Rate the app")
        /// Export logs
        public static let exportLogs = L10n.tr("Localizable", "root.debug.option.exportLogs", fallback: "Export logs")
        /// Go To Onboarding
        public static let gotoOnboarding = L10n.tr("Localizable", "root.debug.option.gotoOnboarding", fallback: "Go To Onboarding")
        /// Go To Phrase Validation Demo
        public static let gotoPhraseValidationDemo = L10n.tr("Localizable", "root.debug.option.gotoPhraseValidationDemo", fallback: "Go To Phrase Validation Demo")
        /// Go To Sandbox (navigation proof)
        public static let gotoSandbox = L10n.tr("Localizable", "root.debug.option.gotoSandbox", fallback: "Go To Sandbox (navigation proof)")
        /// [Be careful] Nuke Wallet
        public static let nukeWallet = L10n.tr("Localizable", "root.debug.option.nukeWallet", fallback: "[Be careful] Nuke Wallet")
        /// Rescan Blockchain
        public static let rescanBlockchain = L10n.tr("Localizable", "root.debug.option.rescanBlockchain", fallback: "Rescan Blockchain")
        /// Restart the app
        public static let restartApp = L10n.tr("Localizable", "root.debug.option.restartApp", fallback: "Restart the app")
        /// Test Crash Reporter
        public static let testCrashReporter = L10n.tr("Localizable", "root.debug.option.testCrashReporter", fallback: "Test Crash Reporter")
      }
    }
    public enum Destination {
      public enum Alert {
        public enum FailedToProcessDeeplink {
          /// Deeplink: (%@))
          /// Error: (%@) (code: %@)
          public static func message(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
            return L10n.tr("Localizable", "root.destination.alert.failedToProcessDeeplink.message", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Deeplink: (%@))\nError: (%@) (code: %@)")
          }
          /// Failed to process deeplink.
          public static let title = L10n.tr("Localizable", "root.destination.alert.failedToProcessDeeplink.title", fallback: "Failed to process deeplink.")
        }
      }
    }
    public enum Initialization {
      public enum Alert {
        public enum CantCreateNewWallet {
          /// Can't create new wallet. Error: %@ (code: %@)
          public static func message(_ p1: Any, _ p2: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.cantCreateNewWallet.message", String(describing: p1), String(describing: p2), fallback: "Can't create new wallet. Error: %@ (code: %@)")
          }
        }
        public enum CantLoadSeedPhrase {
          /// Can't load seed phrase from local storage.
          public static let message = L10n.tr("Localizable", "root.initialization.alert.cantLoadSeedPhrase.message", fallback: "Can't load seed phrase from local storage.")
        }
        public enum CantStoreThatUserPassedPhraseBackupTest {
          /// Can't store information that user passed phrase backup test. Error: %@ (code: %@)
          public static func message(_ p1: Any, _ p2: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.cantStoreThatUserPassedPhraseBackupTest.message", String(describing: p1), String(describing: p2), fallback: "Can't store information that user passed phrase backup test. Error: %@ (code: %@)")
          }
        }
        public enum Error {
          /// Error: %@ (code: %@)
          public static func message(_ p1: Any, _ p2: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.error.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
          }
        }
        public enum Failed {
          /// Wallet initialisation failed.
          public static let title = L10n.tr("Localizable", "root.initialization.alert.failed.title", fallback: "Wallet initialisation failed.")
        }
        public enum SdkInitFailed {
          /// Failed to initialize the SDK
          public static let title = L10n.tr("Localizable", "root.initialization.alert.sdkInitFailed.title", fallback: "Failed to initialize the SDK")
        }
        public enum WalletStateFailed {
          /// App initialisation state: %@.
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.walletStateFailed.message", String(describing: p1), fallback: "App initialisation state: %@.")
          }
        }
        public enum Wipe {
          /// Are you sure?
          public static let message = L10n.tr("Localizable", "root.initialization.alert.wipe.message", fallback: "Are you sure?")
          /// Wipe of the wallet
          public static let title = L10n.tr("Localizable", "root.initialization.alert.wipe.title", fallback: "Wipe of the wallet")
        }
        public enum WipeFailed {
          /// Nuke of the wallet failed
          public static let title = L10n.tr("Localizable", "root.initialization.alert.wipeFailed.title", fallback: "Nuke of the wallet failed")
        }
      }
    }
  }
  public enum Scan {
    /// We will validate any Zcash URI and take you to the appropriate action.
    public static let info = L10n.tr("Localizable", "scan.info", fallback: "We will validate any Zcash URI and take you to the appropriate action.")
    /// Scanning...
    public static let scanning = L10n.tr("Localizable", "scan.scanning", fallback: "Scanning...")
    public enum Alert {
      public enum CantInitializeCamera {
        /// Error: %@ (code: %@)
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "scan.alert.cantInitializeCamera.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
        }
        /// Can't initialize the camera
        public static let title = L10n.tr("Localizable", "scan.alert.cantInitializeCamera.title", fallback: "Can't initialize the camera")
      }
    }
  }
  public enum Send {
    ///  address: %@
    public static func address(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.address", String(describing: p1), fallback: " address: %@")
    }
    /// amount: %@
    public static func amount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.amount", String(describing: p1), fallback: "amount: %@")
    }
    /// Memo included. Tap to edit.
    public static let editMemo = L10n.tr("Localizable", "send.editMemo", fallback: "Memo included. Tap to edit.")
    /// Sending transaction failed
    public static let failed = L10n.tr("Localizable", "send.failed", fallback: "Sending transaction failed")
    /// Aditional funds may be in transit
    public static let fundsInfo = L10n.tr("Localizable", "send.fundsInfo", fallback: "Aditional funds may be in transit")
    /// Want to include memo? Tap here.
    public static let includeMemo = L10n.tr("Localizable", "send.includeMemo", fallback: "Want to include memo? Tap here.")
    ///  memo: %@
    public static func memo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.memo", String(describing: p1), fallback: " memo: %@")
    }
    /// Write a private message here
    public static let memoPlaceholder = L10n.tr("Localizable", "send.memoPlaceholder", fallback: "Write a private message here")
    /// Sending %@ %@ to
    public static func sendingTo(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "send.sendingTo", String(describing: p1), String(describing: p2), fallback: "Sending %@ %@ to")
    }
    /// Sending transaction succeeded
    public static let succeeded = L10n.tr("Localizable", "send.succeeded", fallback: "Sending transaction succeeded")
    /// Send Zcash
    public static let title = L10n.tr("Localizable", "send.title", fallback: "Send Zcash")
  }
  public enum Settings {
    /// About
    public static let about = L10n.tr("Localizable", "settings.about", fallback: "About")
    /// Backup Wallet
    public static let backupWallet = L10n.tr("Localizable", "settings.backupWallet", fallback: "Backup Wallet")
    /// Enable Crash Reporting
    public static let crashReporting = L10n.tr("Localizable", "settings.crashReporting", fallback: "Enable Crash Reporting")
    /// Exporting...
    public static let exporting = L10n.tr("Localizable", "settings.exporting", fallback: "Exporting...")
    /// Export & share logs
    public static let exportLogs = L10n.tr("Localizable", "settings.exportLogs", fallback: "Export & share logs")
    /// Send us feedback!
    public static let feedback = L10n.tr("Localizable", "settings.feedback", fallback: "Send us feedback!")
    /// Settings
    public static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    /// Version %@ (%@)
    public static func version(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
    }
    public enum Alert {
      public enum CantBackupWallet {
        /// Error: %@ (code: %@)
        public static func message(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "settings.alert.cantBackupWallet.message", String(describing: p1), String(describing: p2), fallback: "Error: %@ (code: %@)")
        }
        /// Can't backup wallet
        public static let title = L10n.tr("Localizable", "settings.alert.cantBackupWallet.title", fallback: "Can't backup wallet")
      }
      public enum CantSendEmail {
        /// It looks like that you don't have any email account configured on your device. Therefore it's not possible to send a support email.
        public static let message = L10n.tr("Localizable", "settings.alert.cantSendEmail.message", fallback: "It looks like that you don't have any email account configured on your device. Therefore it's not possible to send a support email.")
        /// Can't send email
        public static let title = L10n.tr("Localizable", "settings.alert.cantSendEmail.title", fallback: "Can't send email")
      }
    }
  }
  public enum SupportData {
    public enum AppVersionItem {
      /// App identifier
      public static let bundleIdentifier = L10n.tr("Localizable", "supportData.appVersionItem.bundleIdentifier", fallback: "App identifier")
      /// App version
      public static let version = L10n.tr("Localizable", "supportData.appVersionItem.version", fallback: "App version")
    }
    public enum DeviceModelItem {
      /// Device
      public static let device = L10n.tr("Localizable", "supportData.deviceModelItem.device", fallback: "Device")
    }
    public enum FreeDiskSpaceItem {
      /// Usable storage
      public static let freeDiskSpace = L10n.tr("Localizable", "supportData.freeDiskSpaceItem.freeDiskSpace", fallback: "Usable storage")
    }
    public enum LocaleItem {
      /// Currency decimal separator
      public static let decimalSeparator = L10n.tr("Localizable", "supportData.localeItem.decimalSeparator", fallback: "Currency decimal separator")
      /// Currency grouping separator
      public static let groupingSeparator = L10n.tr("Localizable", "supportData.localeItem.groupingSeparator", fallback: "Currency grouping separator")
      /// Locale
      public static let locale = L10n.tr("Localizable", "supportData.localeItem.locale", fallback: "Locale")
    }
    public enum PermissionItem {
      /// Camera access
      public static let camera = L10n.tr("Localizable", "supportData.permissionItem.camera", fallback: "Camera access")
      /// FaceID available
      public static let faceID = L10n.tr("Localizable", "supportData.permissionItem.faceID", fallback: "FaceID available")
      /// Permissions
      public static let permissions = L10n.tr("Localizable", "supportData.permissionItem.permissions", fallback: "Permissions")
      /// TouchID available
      public static let touchID = L10n.tr("Localizable", "supportData.permissionItem.touchID", fallback: "TouchID available")
    }
    public enum SystemVersionItem {
      /// iOS version
      public static let version = L10n.tr("Localizable", "supportData.systemVersionItem.version", fallback: "iOS version")
    }
    public enum TimeItem {
      /// Current time
      public static let time = L10n.tr("Localizable", "supportData.timeItem.time", fallback: "Current time")
    }
  }
  public enum Sync {
    public enum Message {
      /// Error: %@
      public static func error(_ p1: Any) -> String {
        return L10n.tr("Localizable", "sync.message.error", String(describing: p1), fallback: "Error: %@")
      }
      /// %@%% Synced
      public static func sync(_ p1: Any) -> String {
        return L10n.tr("Localizable", "sync.message.sync", String(describing: p1), fallback: "%@%% Synced")
      }
      /// Unprepared
      public static let unprepared = L10n.tr("Localizable", "sync.message.unprepared", fallback: "Unprepared")
      /// Up-To-Date
      public static let uptodate = L10n.tr("Localizable", "sync.message.uptodate", fallback: "Up-To-Date")
    }
  }
  public enum Transaction {
    /// Confirmed
    public static let confirmed = L10n.tr("Localizable", "transaction.confirmed", fallback: "Confirmed")
    /// %@ times
    public static func confirmedTimes(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.confirmedTimes", String(describing: p1), fallback: "%@ times")
    }
    /// Confirming ~%@mins
    public static func confirming(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.confirming", String(describing: p1), fallback: "Confirming ~%@mins")
    }
    /// Failed
    public static let failed = L10n.tr("Localizable", "transaction.failed", fallback: "Failed")
    /// Received
    public static let received = L10n.tr("Localizable", "transaction.received", fallback: "Received")
    /// RECEIVING
    public static let receiving = L10n.tr("Localizable", "transaction.receiving", fallback: "RECEIVING")
    /// SENDING
    public static let sending = L10n.tr("Localizable", "transaction.sending", fallback: "SENDING")
    /// Sent
    public static let sent = L10n.tr("Localizable", "transaction.sent", fallback: "Sent")
    /// to
    public static let to = L10n.tr("Localizable", "transaction.to", fallback: "to")
    /// unconfirmed
    public static let unconfirmed = L10n.tr("Localizable", "transaction.unconfirmed", fallback: "unconfirmed")
    /// With memo:
    public static let withMemo = L10n.tr("Localizable", "transaction.withMemo", fallback: "With memo:")
    /// You are receiving %@ %@
    public static func youAreReceiving(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "transaction.youAreReceiving", String(describing: p1), String(describing: p2), fallback: "You are receiving %@ %@")
    }
    /// You are sending %@ %@
    public static func youAreSending(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "transaction.youAreSending", String(describing: p1), String(describing: p2), fallback: "You are sending %@ %@")
    }
    /// You DID NOT send %@ %@
    public static func youDidNotSent(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "transaction.youDidNotSent", String(describing: p1), String(describing: p2), fallback: "You DID NOT send %@ %@")
    }
    /// You received %@ %@
    public static func youReceived(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "transaction.youReceived", String(describing: p1), String(describing: p2), fallback: "You received %@ %@")
    }
    /// You sent %@ %@
    public static func youSent(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "transaction.youSent", String(describing: p1), String(describing: p2), fallback: "You sent %@ %@")
    }
  }
  public enum TransactionDetail {
    /// Error: %@
    public static func error(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transactionDetail.error", String(describing: p1), fallback: "Error: %@")
    }
    /// Transaction detail
    public static let title = L10n.tr("Localizable", "transactionDetail.title", fallback: "Transaction detail")
  }
  public enum Transactions {
    /// Transactions
    public static let title = L10n.tr("Localizable", "transactions.title", fallback: "Transactions")
  }
  public enum ValidationFailed {
    /// Your placed words did not match your secret recovery phrase.
    public static let description = L10n.tr("Localizable", "validationFailed.description", fallback: "Your placed words did not match your secret recovery phrase.")
    /// Remember, you can't recover your funds if you lose (or incorrectly save) these 24 words.
    public static let incorrectBackupDescription = L10n.tr("Localizable", "validationFailed.incorrectBackupDescription", fallback: "Remember, you can't recover your funds if you lose (or incorrectly save) these 24 words.")
    /// Ouch, sorry, no.
    public static let title = L10n.tr("Localizable", "validationFailed.title", fallback: "Ouch, sorry, no.")
    public enum Button {
      /// Try again
      public static let tryAgain = L10n.tr("Localizable", "validationFailed.button.tryAgain", fallback: "Try again")
    }
  }
  public enum ValidationSuccess {
    /// Place that backup somewhere safe and venture forth in security.
    public static let description = L10n.tr("Localizable", "validationSuccess.description", fallback: "Place that backup somewhere safe and venture forth in security.")
    /// Success!
    public static let title = L10n.tr("Localizable", "validationSuccess.title", fallback: "Success!")
    public enum Button {
      /// Take me to my wallet!
      public static let goToWallet = L10n.tr("Localizable", "validationSuccess.button.goToWallet", fallback: "Take me to my wallet!")
      /// Show me my phrase again
      public static let phraseAgain = L10n.tr("Localizable", "validationSuccess.button.phraseAgain", fallback: "Show me my phrase again")
    }
  }
  public enum WalletEvent {
    public enum Alert {
      public enum LeavingApp {
        /// While usually an acceptable risk, you will possibly exposing your behavior and interest in this transaction by going online. OH NOES! What will you do?
        public static let message = L10n.tr("Localizable", "walletEvent.alert.leavingApp.message", fallback: "While usually an acceptable risk, you will possibly exposing your behavior and interest in this transaction by going online. OH NOES! What will you do?")
        /// You are exiting your wallet
        public static let title = L10n.tr("Localizable", "walletEvent.alert.leavingApp.title", fallback: "You are exiting your wallet")
        public enum Button {
          /// NEVERMIND
          public static let nevermind = L10n.tr("Localizable", "walletEvent.alert.leavingApp.button.nevermind", fallback: "NEVERMIND")
          /// SEE TX ONLINE
          public static let seeOnline = L10n.tr("Localizable", "walletEvent.alert.leavingApp.button.seeOnline", fallback: "SEE TX ONLINE")
        }
      }
    }
    public enum Detail {
      /// wallet import wallet event
      public static let `import` = L10n.tr("Localizable", "walletEvent.detail.import", fallback: "wallet import wallet event")
      /// shielded %@ detail
      public static func shielded(_ p1: Any) -> String {
        return L10n.tr("Localizable", "walletEvent.detail.shielded", String(describing: p1), fallback: "shielded %@ detail")
      }
    }
    public enum Row {
      /// wallet import wallet event
      public static let `import` = L10n.tr("Localizable", "walletEvent.row.import", fallback: "wallet import wallet event")
      /// shielded wallet event %@
      public static func shielded(_ p1: Any) -> String {
        return L10n.tr("Localizable", "walletEvent.row.shielded", String(describing: p1), fallback: "shielded wallet event %@")
      }
    }
  }
  public enum WelcomeScreen {
    /// Just Loading, one sec
    public static let subtitle = L10n.tr("Localizable", "welcomeScreen.subtitle", fallback: "Just Loading, one sec")
    /// Powered by Zcash
    public static let title = L10n.tr("Localizable", "welcomeScreen.title", fallback: "Powered by Zcash")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
