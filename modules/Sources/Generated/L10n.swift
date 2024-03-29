// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// QR Code for %@
  public static func qrCodeFor(_ p1: Any) -> String {
    return L10n.tr("Localizable", "qrCodeFor", String(describing: p1), fallback: "QR Code for %@")
  }
  public enum AddressDetails {
    /// Copy
    public static let copy = L10n.tr("Localizable", "addressDetails.copy", fallback: "Copy")
    /// Receive
    public static let receiveTitle = L10n.tr("Localizable", "addressDetails.receiveTitle", fallback: "Receive")
    /// Sapling Address
    public static let sa = L10n.tr("Localizable", "addressDetails.sa", fallback: "Sapling Address")
    /// Share
    public static let share = L10n.tr("Localizable", "addressDetails.share", fallback: "Share")
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
    /// Available balance %@ %@
    public static func available(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "balance.available", String(describing: p1), String(describing: p2), fallback: "Available balance %@ %@")
    }
    /// Available Balance
    public static let availableTitle = L10n.tr("Localizable", "balance.availableTitle", fallback: "Available Balance")
  }
  public enum Balances {
    /// Change pending
    public static let changePending = L10n.tr("Localizable", "balances.changePending", fallback: "Change pending")
    /// Pending transactions
    public static let pendingTransactions = L10n.tr("Localizable", "balances.pendingTransactions", fallback: "Pending transactions")
    /// The restore process can take several hours on lower-powered devices, and even on powerful devices is likely to take more than an hour.
    public static let restoringWalletWarning = L10n.tr("Localizable", "balances.restoringWalletWarning", fallback: "The restore process can take several hours on lower-powered devices, and even on powerful devices is likely to take more than an hour.")
    /// Shield and consolidate funds
    public static let shieldButtonTitle = L10n.tr("Localizable", "balances.shieldButtonTitle", fallback: "Shield and consolidate funds")
    /// Shielding funds
    public static let shieldingInProgress = L10n.tr("Localizable", "balances.shieldingInProgress", fallback: "Shielding funds")
    /// Shielded zec (spendable)
    public static let spendableBalance = L10n.tr("Localizable", "balances.spendableBalance", fallback: "Shielded zec (spendable)")
    /// Synced
    public static let synced = L10n.tr("Localizable", "balances.synced", fallback: "Synced")
    /// Syncing
    public static let syncing = L10n.tr("Localizable", "balances.syncing", fallback: "Syncing")
    /// Zashi encountered an error while syncing, attempting to resolve...
    public static let syncingError = L10n.tr("Localizable", "balances.syncingError", fallback: "Zashi encountered an error while syncing, attempting to resolve...")
    /// Transparent balance
    public static let transparentBalance = L10n.tr("Localizable", "balances.transparentBalance", fallback: "Transparent balance")
    public enum Alert {
      public enum ShieldFunds {
        public enum Failure {
          /// Error: %@
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "balances.alert.shieldFunds.failure.message", String(describing: p1), fallback: "Error: %@")
          }
          /// Failed to shield funds
          public static let title = L10n.tr("Localizable", "balances.alert.shieldFunds.failure.title", fallback: "Failed to shield funds")
        }
      }
    }
    public enum HintBox {
      /// I got it!
      public static let dismiss = L10n.tr("Localizable", "balances.hintBox.dismiss", fallback: "I got it!")
      /// Zashi uses the latest network upgrade and does not support sending transparent (unshielded) ZEC. Use the Shield and Consolidate button to shield your funds, which will add to your available balance and make your ZEC spendable.
      public static let message = L10n.tr("Localizable", "balances.hintBox.message", fallback: "Zashi uses the latest network upgrade and does not support sending transparent (unshielded) ZEC. Use the Shield and Consolidate button to shield your funds, which will add to your available balance and make your ZEC spendable.")
    }
  }
  public enum DeleteWallet {
    /// Delete Zashi
    public static let actionButtonTitle = L10n.tr("Localizable", "deleteWallet.actionButtonTitle", fallback: "Delete Zashi")
    /// I understand
    public static let iUnderstand = L10n.tr("Localizable", "deleteWallet.iUnderstand", fallback: "I understand")
    /// Please don't delete this app unless you're sure you understand the effects.
    public static let message1 = L10n.tr("Localizable", "deleteWallet.message1", fallback: "Please don't delete this app unless you're sure you understand the effects.")
    /// Deleting the Zashi app will delete the database and cached data. Any funds you have in this wallet will be lost and can only be recovered by using your Zashi secret recovery phrase in Zashi or another Zcash wallet.
    public static let message2 = L10n.tr("Localizable", "deleteWallet.message2", fallback: "Deleting the Zashi app will delete the database and cached data. Any funds you have in this wallet will be lost and can only be recovered by using your Zashi secret recovery phrase in Zashi or another Zcash wallet.")
    /// Delete Zashi
    public static let title = L10n.tr("Localizable", "deleteWallet.title", fallback: "Delete Zashi")
  }
  public enum Error {
    /// possible roll back
    public static let rollBack = L10n.tr("Localizable", "error.rollBack", fallback: "possible roll back")
  }
  public enum ExportLogs {
    public enum Alert {
      public enum Failed {
        /// Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "exportLogs.alert.failed.message", String(describing: p1), fallback: "Error: %@")
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
      /// Zcash Address
      public static let validZcashAddress = L10n.tr("Localizable", "field.transactionAddress.validZcashAddress", fallback: "Zcash Address")
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
    /// Done
    public static let done = L10n.tr("Localizable", "general.done", fallback: "Done")
    /// Typical Fee < %@
    public static func fee(_ p1: Any) -> String {
      return L10n.tr("Localizable", "general.fee", String(describing: p1), fallback: "Typical Fee < %@")
    }
    /// Max
    public static let max = L10n.tr("Localizable", "general.max", fallback: "Max")
    /// Next
    public static let next = L10n.tr("Localizable", "general.next", fallback: "Next")
    /// No
    public static let no = L10n.tr("Localizable", "general.no", fallback: "No")
    /// Ok
    public static let ok = L10n.tr("Localizable", "general.ok", fallback: "Ok")
    /// [RESTORING YOUR WALLET…]
    public static let restoringWallet = L10n.tr("Localizable", "general.restoringWallet", fallback: "[RESTORING YOUR WALLET…]")
    /// Save
    public static let save = L10n.tr("Localizable", "general.save", fallback: "Save")
    /// Send
    public static let send = L10n.tr("Localizable", "general.send", fallback: "Send")
    /// Skip
    public static let skip = L10n.tr("Localizable", "general.skip", fallback: "Skip")
    /// Success
    public static let success = L10n.tr("Localizable", "general.success", fallback: "Success")
    /// Tap to copy
    public static let tapToCopy = L10n.tr("Localizable", "general.tapToCopy", fallback: "Tap to copy")
    /// Unknown
    public static let unknown = L10n.tr("Localizable", "general.unknown", fallback: "Unknown")
    /// Yes
    public static let yes = L10n.tr("Localizable", "general.yes", fallback: "Yes")
  }
  public enum Home {
    /// Upgrading databases…
    public static let migratingDatabases = L10n.tr("Localizable", "home.migratingDatabases", fallback: "Upgrading databases…")
    /// Receive %@
    public static func receiveZec(_ p1: Any) -> String {
      return L10n.tr("Localizable", "home.receiveZec", String(describing: p1), fallback: "Receive %@")
    }
    /// Send %@
    public static func sendZec(_ p1: Any) -> String {
      return L10n.tr("Localizable", "home.sendZec", String(describing: p1), fallback: "Send %@")
    }
  }
  public enum ImportWallet {
    /// Enter secret
    /// recovery phrase
    public static let description = L10n.tr("Localizable", "importWallet.description", fallback: "Enter secret\nrecovery phrase")
    /// Enter private seed here…
    public static let enterPlaceholder = L10n.tr("Localizable", "importWallet.enterPlaceholder", fallback: "Enter private seed here…")
    /// Enter your 24-word seed phrase to restore the associated wallet.
    public static let message = L10n.tr("Localizable", "importWallet.message", fallback: "Enter your 24-word seed phrase to restore the associated wallet.")
    /// (optional)
    public static let optionalBirthday = L10n.tr("Localizable", "importWallet.optionalBirthday", fallback: "(optional)")
    /// Wallet Import
    public static let title = L10n.tr("Localizable", "importWallet.title", fallback: "Wallet Import")
    public enum Alert {
      public enum Failed {
        /// Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "importWallet.alert.failed.message", String(describing: p1), fallback: "Error: %@")
        }
        /// Failed to restore wallet
        public static let title = L10n.tr("Localizable", "importWallet.alert.failed.title", fallback: "Failed to restore wallet")
      }
      public enum Success {
        /// Your wallet has been successfully restored! During the initial sync, your funds cannot be spent or sent. Depending on the age of your wallet, it may take a few hours to fully sync.
        public static let message = L10n.tr("Localizable", "importWallet.alert.success.message", fallback: "Your wallet has been successfully restored! During the initial sync, your funds cannot be spent or sent. Depending on the age of your wallet, it may take a few hours to fully sync.")
        /// Success
        public static let title = L10n.tr("Localizable", "importWallet.alert.success.title", fallback: "Success")
      }
    }
    public enum Birthday {
      /// Wallet birthday height
      public static let title = L10n.tr("Localizable", "importWallet.birthday.title", fallback: "Wallet birthday height")
    }
    public enum Button {
      /// Restore
      public static let restoreWallet = L10n.tr("Localizable", "importWallet.button.restoreWallet", fallback: "Restore")
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
    /// A no-frills wallet for sending and receiving Zcash (ZEC).
    public static let title = L10n.tr("Localizable", "plainOnboarding.title", fallback: "A no-frills wallet for sending and receiving Zcash (ZEC).")
    public enum Button {
      /// Create new Wallet
      public static let createNewWallet = L10n.tr("Localizable", "plainOnboarding.button.createNewWallet", fallback: "Create new Wallet")
      /// Restore existing wallet
      public static let restoreWallet = L10n.tr("Localizable", "plainOnboarding.button.restoreWallet", fallback: "Restore existing wallet")
    }
  }
  public enum PrivateDataConsent {
    /// I agree
    public static let confirmation = L10n.tr("Localizable", "privateDataConsent.confirmation", fallback: "I agree")
    /// By clicking "I Agree" below, you give your consent to export Zashi’s private data which includes the entire history of the wallet, all private information, memos, amounts and recipient addresses, even for your shielded activity.*
    /// 
    /// This private data also gives the ability to see certain future actions you take with Zashi.
    /// 
    /// Sharing this private data is irrevocable — once you have shared this private data with someone, there is no way to revoke their access.
    public static let message = L10n.tr("Localizable", "privateDataConsent.message", fallback: "By clicking \"I Agree\" below, you give your consent to export Zashi’s private data which includes the entire history of the wallet, all private information, memos, amounts and recipient addresses, even for your shielded activity.*\n\nThis private data also gives the ability to see certain future actions you take with Zashi.\n\nSharing this private data is irrevocable — once you have shared this private data with someone, there is no way to revoke their access.")
    /// *Note that this private data does not give them the ability to spend your funds, only the ability to see what you do with your funds.
    public static let note = L10n.tr("Localizable", "privateDataConsent.note", fallback: "*Note that this private data does not give them the ability to spend your funds, only the ability to see what you do with your funds.")
    /// Consent for Exporting Private Data
    public static let title = L10n.tr("Localizable", "privateDataConsent.title", fallback: "Consent for Exporting Private Data")
  }
  public enum ProposalPartial {
    /// Contact Support
    public static let contactSupport = L10n.tr("Localizable", "proposalPartial.contactSupport", fallback: "Contact Support")
    /// Hi Zashi Team,
    public static let mailPart1 = L10n.tr("Localizable", "proposalPartial.mailPart1", fallback: "Hi Zashi Team,")
    /// While sending a transaction to a TEX address, I encountered an error state. I'm reaching out to get guidance on how to recover my funds.
    public static let mailPart2 = L10n.tr("Localizable", "proposalPartial.mailPart2", fallback: "While sending a transaction to a TEX address, I encountered an error state. I'm reaching out to get guidance on how to recover my funds.")
    /// Thank you.
    public static let mailPart3 = L10n.tr("Localizable", "proposalPartial.mailPart3", fallback: "Thank you.")
    /// TEX Transaction Error
    public static let mailSubject = L10n.tr("Localizable", "proposalPartial.mailSubject", fallback: "TEX Transaction Error")
    /// Sending to this recipient required multiple transactions, but only some of them succeeded. Your funds are safe, but they need to be recovered with the help of Zashi team support.
    public static let message1 = L10n.tr("Localizable", "proposalPartial.message1", fallback: "Sending to this recipient required multiple transactions, but only some of them succeeded. Your funds are safe, but they need to be recovered with the help of Zashi team support.")
    /// Please use the button below to contact us and recover your funds. Your message to us will be pre-populated with all the data we need to resolve this issue.
    public static let message2 = L10n.tr("Localizable", "proposalPartial.message2", fallback: "Please use the button below to contact us and recover your funds. Your message to us will be pre-populated with all the data we need to resolve this issue.")
    /// Transaction Error
    public static let title = L10n.tr("Localizable", "proposalPartial.title", fallback: "Transaction Error")
    /// Transaction Ids
    public static let transactionIds = L10n.tr("Localizable", "proposalPartial.transactionIds", fallback: "Transaction Ids")
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
    /// Wallet birthday height: %@
    public static func birthdayHeight(_ p1: Any) -> String {
      return L10n.tr("Localizable", "recoveryPhraseDisplay.birthdayHeight", String(describing: p1), fallback: "Wallet birthday height: %@")
    }
    /// The following 24 words are the keys to your funds and are the only way to recover your funds if you get locked out or get a new device. Protect your ZEC by storing this phrase in a place you trust and never share it with anyone!
    public static let description = L10n.tr("Localizable", "recoveryPhraseDisplay.description", fallback: "The following 24 words are the keys to your funds and are the only way to recover your funds if you get locked out or get a new device. Protect your ZEC by storing this phrase in a place you trust and never share it with anyone!")
    /// The keys are missing. No backup phrase is stored in the keychain.
    public static let noWords = L10n.tr("Localizable", "recoveryPhraseDisplay.noWords", fallback: "The keys are missing. No backup phrase is stored in the keychain.")
    /// Your Secret
    public static let titlePart1 = L10n.tr("Localizable", "recoveryPhraseDisplay.titlePart1", fallback: "Your Secret")
    /// Recovery Phrase
    public static let titlePart2 = L10n.tr("Localizable", "recoveryPhraseDisplay.titlePart2", fallback: "Recovery Phrase")
    public enum Alert {
      public enum Failed {
        /// Attempt to load the stored wallet from the keychain failed. Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "recoveryPhraseDisplay.alert.failed.message", String(describing: p1), fallback: "Attempt to load the stored wallet from the keychain failed. Error: %@")
        }
        /// Failed to load stored wallet
        public static let title = L10n.tr("Localizable", "recoveryPhraseDisplay.alert.failed.title", fallback: "Failed to load stored wallet")
      }
    }
    public enum Button {
      /// Copy To Buffer
      public static let copyToBuffer = L10n.tr("Localizable", "recoveryPhraseDisplay.button.copyToBuffer", fallback: "Copy To Buffer")
      /// I got it!
      public static let wroteItDown = L10n.tr("Localizable", "recoveryPhraseDisplay.button.wroteItDown", fallback: "I got it!")
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
      /// Support options
      public static let title = L10n.tr("Localizable", "root.debug.title", fallback: "Support options")
      public enum Alert {
        public enum Rewind {
          public enum CantStartSync {
            /// Error: %@
            public static func message(_ p1: Any) -> String {
              return L10n.tr("Localizable", "root.debug.alert.rewind.cantStartSync.message", String(describing: p1), fallback: "Error: %@")
            }
            /// Can't start sync process after rewind
            public static let title = L10n.tr("Localizable", "root.debug.alert.rewind.cantStartSync.title", fallback: "Can't start sync process after rewind")
          }
          public enum Failed {
            /// Error: %@
            public static func message(_ p1: Any) -> String {
              return L10n.tr("Localizable", "root.debug.alert.rewind.failed.message", String(describing: p1), fallback: "Error: %@")
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
        /// Rate the App
        public static let appReview = L10n.tr("Localizable", "root.debug.option.appReview", fallback: "Rate the App")
        /// Copy seed to pasteboard
        public static let copySeed = L10n.tr("Localizable", "root.debug.option.copySeed", fallback: "Copy seed to pasteboard")
        /// Export Logs
        public static let exportLogs = L10n.tr("Localizable", "root.debug.option.exportLogs", fallback: "Export Logs")
        /// [Be careful] Nuke Wallet
        public static let nukeWallet = L10n.tr("Localizable", "root.debug.option.nukeWallet", fallback: "[Be careful] Nuke Wallet")
        /// Rescan Blockchain
        public static let rescanBlockchain = L10n.tr("Localizable", "root.debug.option.rescanBlockchain", fallback: "Rescan Blockchain")
        /// Restart the App
        public static let restartApp = L10n.tr("Localizable", "root.debug.option.restartApp", fallback: "Restart the App")
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
          /// Can't create new wallet. Error: %@
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.cantCreateNewWallet.message", String(describing: p1), fallback: "Can't create new wallet. Error: %@")
          }
        }
        public enum CantLoadSeedPhrase {
          /// Can't load seed phrase from local storage.
          public static let message = L10n.tr("Localizable", "root.initialization.alert.cantLoadSeedPhrase.message", fallback: "Can't load seed phrase from local storage.")
        }
        public enum CantStoreThatUserPassedPhraseBackupTest {
          /// Can't store information that user passed phrase backup test. Error: %@
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.cantStoreThatUserPassedPhraseBackupTest.message", String(describing: p1), fallback: "Can't store information that user passed phrase backup test. Error: %@")
          }
        }
        public enum Error {
          /// Error: %@
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "root.initialization.alert.error.message", String(describing: p1), fallback: "Error: %@")
          }
        }
        public enum Failed {
          /// Wallet initialisation failed.
          public static let title = L10n.tr("Localizable", "root.initialization.alert.failed.title", fallback: "Wallet initialisation failed.")
        }
        public enum RetryStartFailed {
          /// The app was in background so re-start of the synchronizer is needed but this operation failed.
          public static let message = L10n.tr("Localizable", "root.initialization.alert.retryStartFailed.message", fallback: "The app was in background so re-start of the synchronizer is needed but this operation failed.")
          /// Synchronizer failed to start
          public static let title = L10n.tr("Localizable", "root.initialization.alert.retryStartFailed.title", fallback: "Synchronizer failed to start")
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
    /// The camera is not authorized. Please go to the system settings of Zashi and turn it on.
    public static let cameraSettings = L10n.tr("Localizable", "scan.cameraSettings", fallback: "The camera is not authorized. Please go to the system settings of Zashi and turn it on.")
    /// This QR code doesn't hold a valid Zcash address.
    public static let invalidQR = L10n.tr("Localizable", "scan.invalidQR", fallback: "This QR code doesn't hold a valid Zcash address.")
  }
  public enum SecurityWarning {
    /// I acknowledge
    public static let acknowledge = L10n.tr("Localizable", "securityWarning.acknowledge", fallback: "I acknowledge")
    /// Confirm
    public static let confirm = L10n.tr("Localizable", "securityWarning.confirm", fallback: "Confirm")
    /// Security warning:
    public static let title = L10n.tr("Localizable", "securityWarning.title", fallback: "Security warning:")
    /// Zashi %@ (%@) is a Zcash-only, shielded wallet — built by Zcashers for Zcashers. Zashi has been engineered for your privacy and safety. By installing and using Zashi, you consent to share crash reports with Electric Coin Co. (the wallet developer), which will help us improve the Zashi user experience.*
    public static func warningA(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "securityWarning.warningA", String(describing: p1), String(describing: p2), fallback: "Zashi %@ (%@) is a Zcash-only, shielded wallet — built by Zcashers for Zcashers. Zashi has been engineered for your privacy and safety. By installing and using Zashi, you consent to share crash reports with Electric Coin Co. (the wallet developer), which will help us improve the Zashi user experience.*")
    }
    /// Please acknowledge and confirm below to proceed.
    public static let warningB = L10n.tr("Localizable", "securityWarning.warningB", fallback: "Please acknowledge and confirm below to proceed.")
    /// *Note
    public static let warningC = L10n.tr("Localizable", "securityWarning.warningC", fallback: "*Note")
    /// : Crash reports might reveal the timing of the crash and what events occurred, but do not reveal spending or viewing keys.
    public static let warningD = L10n.tr("Localizable", "securityWarning.warningD", fallback: ": Crash reports might reveal the timing of the crash and what events occurred, but do not reveal spending or viewing keys.")
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
    /// Amount:
    public static let amountSummary = L10n.tr("Localizable", "send.amountSummary", fallback: "Amount:")
    /// Confirmation
    public static let confirmationTitle = L10n.tr("Localizable", "send.confirmationTitle", fallback: "Confirmation")
    /// Memo included. Tap to edit.
    public static let editMemo = L10n.tr("Localizable", "send.editMemo", fallback: "Memo included. Tap to edit.")
    /// Sending transaction failed
    public static let failed = L10n.tr("Localizable", "send.failed", fallback: "Sending transaction failed")
    /// Fee:
    public static let feeSummary = L10n.tr("Localizable", "send.feeSummary", fallback: "Fee:")
    /// Aditional funds may be in transit
    public static let fundsInfo = L10n.tr("Localizable", "send.fundsInfo", fallback: "Aditional funds may be in transit")
    /// Go back
    public static let goBack = L10n.tr("Localizable", "send.goBack", fallback: "Go back")
    /// Want to include memo? Tap here.
    public static let includeMemo = L10n.tr("Localizable", "send.includeMemo", fallback: "Want to include memo? Tap here.")
    ///  memo: %@
    public static func memo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.memo", String(describing: p1), fallback: " memo: %@")
    }
    /// Write private message here...
    public static let memoPlaceholder = L10n.tr("Localizable", "send.memoPlaceholder", fallback: "Write private message here...")
    /// Message
    public static let message = L10n.tr("Localizable", "send.message", fallback: "Message")
    /// Review
    public static let review = L10n.tr("Localizable", "send.review", fallback: "Review")
    /// Sending
    public static let sending = L10n.tr("Localizable", "send.sending", fallback: "Sending")
    /// Sending %@ %@ to
    public static func sendingTo(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "send.sendingTo", String(describing: p1), String(describing: p2), fallback: "Sending %@ %@ to")
    }
    /// Sending transaction succeeded
    public static let succeeded = L10n.tr("Localizable", "send.succeeded", fallback: "Sending transaction succeeded")
    /// Send Zcash
    public static let title = L10n.tr("Localizable", "send.title", fallback: "Send Zcash")
    /// To:
    public static let toSummary = L10n.tr("Localizable", "send.toSummary", fallback: "To:")
    public enum Alert {
      public enum Failure {
        /// Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "send.alert.failure.message", String(describing: p1), fallback: "Error: %@")
        }
        /// Failed to send funds
        public static let title = L10n.tr("Localizable", "send.alert.failure.title", fallback: "Failed to send funds")
      }
    }
    public enum Error {
      /// Insufficient funds
      public static let insufficientFunds = L10n.tr("Localizable", "send.error.insufficientFunds", fallback: "Insufficient funds")
      /// Invalid address
      public static let invalidAddress = L10n.tr("Localizable", "send.error.invalidAddress", fallback: "Invalid address")
      /// Invalid amount
      public static let invalidAmount = L10n.tr("Localizable", "send.error.invalidAmount", fallback: "Invalid amount")
    }
  }
  public enum ServerSetup {
    /// <hostname>:<port>
    public static let placeholder = L10n.tr("Localizable", "serverSetup.placeholder", fallback: "<hostname>:<port>")
    /// Server
    public static let title = L10n.tr("Localizable", "serverSetup.title", fallback: "Server")
    public enum Alert {
      public enum Failed {
        /// Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "serverSetup.alert.failed.message", String(describing: p1), fallback: "Error: %@")
        }
        /// Invalid endpoint
        public static let title = L10n.tr("Localizable", "serverSetup.alert.failed.title", fallback: "Invalid endpoint")
      }
    }
  }
  public enum Settings {
    /// About
    public static let about = L10n.tr("Localizable", "settings.about", fallback: "About")
    /// Advanced
    public static let advanced = L10n.tr("Localizable", "settings.advanced", fallback: "Advanced")
    /// Choose a server
    public static let chooseServer = L10n.tr("Localizable", "settings.chooseServer", fallback: "Choose a server")
    /// Delete Zashi
    public static let deleteZashi = L10n.tr("Localizable", "settings.deleteZashi", fallback: "Delete Zashi")
    /// (You will be asked to confirm on next screen)
    public static let deleteZashiWarning = L10n.tr("Localizable", "settings.deleteZashiWarning", fallback: "(You will be asked to confirm on next screen)")
    /// Export logs only
    public static let exportLogsOnly = L10n.tr("Localizable", "settings.exportLogsOnly", fallback: "Export logs only")
    /// Export private data
    public static let exportPrivateData = L10n.tr("Localizable", "settings.exportPrivateData", fallback: "Export private data")
    /// Send us feedback
    public static let feedback = L10n.tr("Localizable", "settings.feedback", fallback: "Send us feedback")
    /// See our Privacy Policy 
    public static let privacyPolicyPart1 = L10n.tr("Localizable", "settings.privacyPolicyPart1", fallback: "See our Privacy Policy ")
    /// here.
    public static let privacyPolicyPart2 = L10n.tr("Localizable", "settings.privacyPolicyPart2", fallback: "here.")
    /// Recovery Phrase
    public static let recoveryPhrase = L10n.tr("Localizable", "settings.recoveryPhrase", fallback: "Recovery Phrase")
    /// Version %@ (%@)
    public static func version(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
    }
    public enum About {
      /// Send and receive ZEC on Zashi!
      /// Zashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private. Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.
      public static let info = L10n.tr("Localizable", "settings.about.info", fallback: "Send and receive ZEC on Zashi!\nZashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private. Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.")
    }
    public enum Alert {
      public enum CantBackupWallet {
        /// Error: %@
        public static func message(_ p1: Any) -> String {
          return L10n.tr("Localizable", "settings.alert.cantBackupWallet.message", String(describing: p1), fallback: "Error: %@")
        }
        /// Can't backup wallet
        public static let title = L10n.tr("Localizable", "settings.alert.cantBackupWallet.title", fallback: "Can't backup wallet")
      }
      public enum CantSendEmail {
        /// Copy %@
        public static func copyEmail(_ p1: Any) -> String {
          return L10n.tr("Localizable", "settings.alert.cantSendEmail.copyEmail", String(describing: p1), fallback: "Copy %@")
        }
        /// It looks like you don't have a default email app configured on your device. Copy the address below, and use your favorite email client to send us a message.
        public static let message = L10n.tr("Localizable", "settings.alert.cantSendEmail.message", fallback: "It looks like you don't have a default email app configured on your device. Copy the address below, and use your favorite email client to send us a message.")
        /// Oh, no!
        public static let title = L10n.tr("Localizable", "settings.alert.cantSendEmail.title", fallback: "Oh, no!")
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
      /// Stopped
      public static let stopped = L10n.tr("Localizable", "sync.message.stopped", fallback: "Stopped")
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
  public enum Tabs {
    /// Account
    public static let account = L10n.tr("Localizable", "tabs.account", fallback: "Account")
    /// Balances
    public static let balances = L10n.tr("Localizable", "tabs.balances", fallback: "Balances")
    /// Receive
    public static let receive = L10n.tr("Localizable", "tabs.receive", fallback: "Receive")
    /// Send
    public static let send = L10n.tr("Localizable", "tabs.send", fallback: "Send")
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
    /// Receive failed
    public static let failedReceive = L10n.tr("Localizable", "transaction.failedReceive", fallback: "Receive failed")
    /// Send failed
    public static let failedSend = L10n.tr("Localizable", "transaction.failedSend", fallback: "Send failed")
    /// Received
    public static let received = L10n.tr("Localizable", "transaction.received", fallback: "Received")
    /// Receiving...
    public static let receiving = L10n.tr("Localizable", "transaction.receiving", fallback: "Receiving...")
    /// Sending...
    public static let sending = L10n.tr("Localizable", "transaction.sending", fallback: "Sending...")
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
  public enum TransactionList {
    /// Collapse transaction
    public static let collapse = L10n.tr("Localizable", "transactionList.collapse", fallback: "Collapse transaction")
    /// Message
    public static let messageTitle = L10n.tr("Localizable", "transactionList.messageTitle", fallback: "Message")
    /// No message included in transaction
    public static let noMessageIncluded = L10n.tr("Localizable", "transactionList.noMessageIncluded", fallback: "No message included in transaction")
    /// No transaction history
    public static let noTransactions = L10n.tr("Localizable", "transactionList.noTransactions", fallback: "No transaction history")
    /// Transaction Fee
    public static let transactionFee = L10n.tr("Localizable", "transactionList.transactionFee", fallback: "Transaction Fee")
    /// Transaction ID
    public static let transactionId = L10n.tr("Localizable", "transactionList.transactionId", fallback: "Transaction ID")
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
