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
  public enum About {
    /// Send and receive ZEC on Zashi!
    /// Zashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private. Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.
    public static let info = L10n.tr("Localizable", "about.info", fallback: "Send and receive ZEC on Zashi!\nZashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private. Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.")
    /// Privacy Policy
    public static let privacyPolicy = L10n.tr("Localizable", "about.privacyPolicy", fallback: "Privacy Policy")
    /// Zashi Version %@ (%@)
    public static func version(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "about.version", String(describing: p1), String(describing: p2), fallback: "Zashi Version %@ (%@)")
    }
    /// What's new
    public static let whatsNew = L10n.tr("Localizable", "about.whatsNew", fallback: "What's new")
  }
  public enum AddressBook {
    /// Add New Contact
    public static let addNewContact = L10n.tr("Localizable", "addressBook.addNewContact", fallback: "Add New Contact")
    /// Your address book is empty
    public static let empty = L10n.tr("Localizable", "addressBook.empty", fallback: "Your address book is empty")
    /// Manual Entry
    public static let manualEntry = L10n.tr("Localizable", "addressBook.manualEntry", fallback: "Manual Entry")
    /// Saved Address
    public static let savedAddress = L10n.tr("Localizable", "addressBook.savedAddress", fallback: "Saved Address")
    /// Scan QR code
    public static let scanAddress = L10n.tr("Localizable", "addressBook.scanAddress", fallback: "Scan QR code")
    /// Select recipient
    public static let selectRecipient = L10n.tr("Localizable", "addressBook.selectRecipient", fallback: "Select recipient")
    /// Address Book
    public static let title = L10n.tr("Localizable", "addressBook.title", fallback: "Address Book")
    public enum Alert {
      /// You are about to delete this contact. This cannot be undone.
      public static let message = L10n.tr("Localizable", "addressBook.alert.message", fallback: "You are about to delete this contact. This cannot be undone.")
      /// Are you sure?
      public static let title = L10n.tr("Localizable", "addressBook.alert.title", fallback: "Are you sure?")
    }
    public enum Error {
      /// This wallet address is already in your Address Book.
      public static let addressExists = L10n.tr("Localizable", "addressBook.error.addressExists", fallback: "This wallet address is already in your Address Book.")
      /// Invalid address.
      public static let invalidAddress = L10n.tr("Localizable", "addressBook.error.invalidAddress", fallback: "Invalid address.")
      /// This contact name is already in use. Please choose a different name.
      public static let nameExists = L10n.tr("Localizable", "addressBook.error.nameExists", fallback: "This contact name is already in use. Please choose a different name.")
      /// This contact name exceeds the 32-character limit. Please shorten the name.
      public static let nameLength = L10n.tr("Localizable", "addressBook.error.nameLength", fallback: "This contact name exceeds the 32-character limit. Please shorten the name.")
    }
    public enum NewContact {
      /// Wallet Address
      public static let address = L10n.tr("Localizable", "addressBook.newContact.address", fallback: "Wallet Address")
      /// Enter wallet address...
      public static let addressPlaceholder = L10n.tr("Localizable", "addressBook.newContact.addressPlaceholder", fallback: "Enter wallet address...")
      /// Contact Name
      public static let name = L10n.tr("Localizable", "addressBook.newContact.name", fallback: "Contact Name")
      /// Enter contact name...
      public static let namePlaceholder = L10n.tr("Localizable", "addressBook.newContact.namePlaceholder", fallback: "Enter contact name...")
      /// Add New Address
      public static let title = L10n.tr("Localizable", "addressBook.newContact.title", fallback: "Add New Address")
    }
  }
  public enum AddressDetails {
    /// Copy
    public static let copy = L10n.tr("Localizable", "addressDetails.copy", fallback: "Copy")
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
    /// Available Balance:
    public static let availableTitle = L10n.tr("Localizable", "balance.availableTitle", fallback: "Available Balance:")
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
  public enum CurrencyConversion {
    /// Review
    public static let cardButton = L10n.tr("Localizable", "currencyConversion.cardButton", fallback: "Review")
    /// New Feature
    public static let cardTitle = L10n.tr("Localizable", "currencyConversion.cardTitle", fallback: "New Feature")
    /// Enable
    public static let enable = L10n.tr("Localizable", "currencyConversion.enable", fallback: "Enable")
    /// Zashi’s currency conversion feature doesn’t compromise your IP address.
    public static let ipDesc = L10n.tr("Localizable", "currencyConversion.ipDesc", fallback: "Zashi’s currency conversion feature doesn’t compromise your IP address.")
    /// IP Address Protection
    public static let ipTitle = L10n.tr("Localizable", "currencyConversion.ipTitle", fallback: "IP Address Protection")
    /// Display your balance and payment amounts in USD. You can manage this feature in Advanced Settings.
    public static let learnMoreDesc = L10n.tr("Localizable", "currencyConversion.learnMoreDesc", fallback: "Display your balance and payment amounts in USD. You can manage this feature in Advanced Settings.")
    /// Disable
    public static let learnMoreOptionDisable = L10n.tr("Localizable", "currencyConversion.learnMoreOptionDisable", fallback: "Disable")
    /// Don’t show the currency conversion.
    public static let learnMoreOptionDisableDesc = L10n.tr("Localizable", "currencyConversion.learnMoreOptionDisableDesc", fallback: "Don’t show the currency conversion.")
    /// Show me the currency conversion.
    public static let learnMoreOptionEnableDesc = L10n.tr("Localizable", "currencyConversion.learnMoreOptionEnableDesc", fallback: "Show me the currency conversion.")
    /// Note for the super privacy-conscious: Because we pull the conversion rate from exchanges, an exchange might be able to see that the exchange rate was queried before a transaction occurred.
    public static let note = L10n.tr("Localizable", "currencyConversion.note", fallback: "Note for the super privacy-conscious: Because we pull the conversion rate from exchanges, an exchange might be able to see that the exchange rate was queried before a transaction occurred.")
    /// Rate Refresh
    public static let refresh = L10n.tr("Localizable", "currencyConversion.refresh", fallback: "Rate Refresh")
    /// The rate is refreshed automatically and can also be refreshed manually.
    public static let refreshDesc = L10n.tr("Localizable", "currencyConversion.refreshDesc", fallback: "The rate is refreshed automatically and can also be refreshed manually.")
    /// Save changes
    public static let saveBtn = L10n.tr("Localizable", "currencyConversion.saveBtn", fallback: "Save changes")
    /// Display your balance and payment amounts in USD. Zashi’s currency conversion feature protects your IP address at all times.
    public static let settingsDesc = L10n.tr("Localizable", "currencyConversion.settingsDesc", fallback: "Display your balance and payment amounts in USD. Zashi’s currency conversion feature protects your IP address at all times.")
    /// Skip for now
    public static let skipBtn = L10n.tr("Localizable", "currencyConversion.skipBtn", fallback: "Skip for now")
    /// Currency Conversion
    public static let title = L10n.tr("Localizable", "currencyConversion.title", fallback: "Currency Conversion")
  }
  public enum DeleteWallet {
    /// Delete
    public static let actionButtonTitle = L10n.tr("Localizable", "deleteWallet.actionButtonTitle", fallback: "Delete")
    /// I understand
    public static let iUnderstand = L10n.tr("Localizable", "deleteWallet.iUnderstand", fallback: "I understand")
    /// Please don't delete this app unless you're sure you understand the effects.
    public static let message1 = L10n.tr("Localizable", "deleteWallet.message1", fallback: "Please don't delete this app unless you're sure you understand the effects.")
    /// Deleting the Zashi app will delete the database and cached data. Any funds you have in this wallet will be lost and can only be recovered by using your Zashi secret recovery phrase in Zashi or another Zcash wallet.
    public static let message2 = L10n.tr("Localizable", "deleteWallet.message2", fallback: "Deleting the Zashi app will delete the database and cached data. Any funds you have in this wallet will be lost and can only be recovered by using your Zashi secret recovery phrase in Zashi or another Zcash wallet.")
    /// Delete Zashi
    public static let title = L10n.tr("Localizable", "deleteWallet.title", fallback: "Delete Zashi")
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
  public enum General {
    /// Back
    public static let back = L10n.tr("Localizable", "general.back", fallback: "Back")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "general.cancel", fallback: "Cancel")
    /// Close
    public static let close = L10n.tr("Localizable", "general.close", fallback: "Close")
    /// Confirm
    public static let confirm = L10n.tr("Localizable", "general.confirm", fallback: "Confirm")
    /// Delete
    public static let delete = L10n.tr("Localizable", "general.delete", fallback: "Delete")
    /// Done
    public static let done = L10n.tr("Localizable", "general.done", fallback: "Done")
    /// Typical Fee < %@
    public static func fee(_ p1: Any) -> String {
      return L10n.tr("Localizable", "general.fee", String(describing: p1), fallback: "Typical Fee < %@")
    }
    /// 
    public static let hideBalancesLeast = L10n.tr("Localizable", "general.hideBalancesLeast", fallback: "")
    /// -----
    public static let hideBalancesMost = L10n.tr("Localizable", "general.hideBalancesMost", fallback: "-----")
    /// -----
    public static let hideBalancesMostStandalone = L10n.tr("Localizable", "general.hideBalancesMostStandalone", fallback: "-----")
    /// Loading
    public static let loading = L10n.tr("Localizable", "general.loading", fallback: "Loading")
    /// Max
    public static let max = L10n.tr("Localizable", "general.max", fallback: "Max")
    /// Next
    public static let next = L10n.tr("Localizable", "general.next", fallback: "Next")
    /// No
    public static let no = L10n.tr("Localizable", "general.no", fallback: "No")
    /// Ok
    public static let ok = L10n.tr("Localizable", "general.ok", fallback: "Ok")
    /// Save
    public static let save = L10n.tr("Localizable", "general.save", fallback: "Save")
    /// Send
    public static let send = L10n.tr("Localizable", "general.send", fallback: "Send")
    /// Success
    public static let success = L10n.tr("Localizable", "general.success", fallback: "Success")
    /// Tap to copy
    public static let tapToCopy = L10n.tr("Localizable", "general.tapToCopy", fallback: "Tap to copy")
    /// Unknown
    public static let unknown = L10n.tr("Localizable", "general.unknown", fallback: "Unknown")
    /// Yes
    public static let yes = L10n.tr("Localizable", "general.yes", fallback: "Yes")
    public enum Alert {
      /// Heads up
      public static let caution = L10n.tr("Localizable", "general.alert.caution", fallback: "Heads up")
      /// Continue
      public static let `continue` = L10n.tr("Localizable", "general.alert.continue", fallback: "Continue")
      /// Ignore
      public static let ignore = L10n.tr("Localizable", "general.alert.ignore", fallback: "Ignore")
      /// Warning
      public static let warning = L10n.tr("Localizable", "general.alert.warning", fallback: "Warning")
    }
  }
  public enum Home {
    /// Upgrading databases…
    public static let migratingDatabases = L10n.tr("Localizable", "home.migratingDatabases", fallback: "Upgrading databases…")
  }
  public enum ImportWallet {
    /// Enter secret
    /// recovery phrase
    public static let description = L10n.tr("Localizable", "importWallet.description", fallback: "Enter secret\nrecovery phrase")
    /// privacy dignity freedom ...
    public static let enterPlaceholder = L10n.tr("Localizable", "importWallet.enterPlaceholder", fallback: "privacy dignity freedom ...")
    /// Enter your 24-word seed phrase to restore the associated wallet.
    public static let message = L10n.tr("Localizable", "importWallet.message", fallback: "Enter your 24-word seed phrase to restore the associated wallet.")
    /// (optional)
    public static let optionalBirthday = L10n.tr("Localizable", "importWallet.optionalBirthday", fallback: "(optional)")
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
  public enum NotEnoughFreeSpace {
    /// Zashi requires at
    /// least %@ GB of space to
    /// operate but there is only
    /// %@ MB available.
    public static func message1(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "notEnoughFreeSpace.message1", String(describing: p1), String(describing: p2), fallback: "Zashi requires at\nleast %@ GB of space to\noperate but there is only\n%@ MB available.")
    }
    /// Go to your device settings and make more space available if you wish to use the Zashi app.
    public static let message2 = L10n.tr("Localizable", "notEnoughFreeSpace.message2", fallback: "Go to your device settings and make more space available if you wish to use the Zashi app.")
    /// Not enough free space
    public static let title = L10n.tr("Localizable", "notEnoughFreeSpace.title", fallback: "Not enough free space")
  }
  public enum Partners {
    /// https://pay.coinbase.com/buy/select-asset?appId=%@&addresses={"%@":["zcash"]}
    public static func coinbaseOnrampUrl(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "partners.coinbaseOnrampUrl", String(describing: p1), String(describing: p2), fallback: "https://pay.coinbase.com/buy/select-asset?appId=%@&addresses={\"%@\":[\"zcash\"]}")
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
      /// I've saved it
      public static let wroteItDown = L10n.tr("Localizable", "recoveryPhraseDisplay.button.wroteItDown", fallback: "I've saved it")
    }
  }
  public enum RestoreInfo {
    /// Got it!
    public static let gotIt = L10n.tr("Localizable", "restoreInfo.gotIt", fallback: "Got it!")
    /// Note: 
    public static let note = L10n.tr("Localizable", "restoreInfo.note", fallback: "Note: ")
    /// During the initial sync your funds cannot be sent or spent. Depending on the age of your wallet, it may take a few hours to fully sync.
    public static let noteInfo = L10n.tr("Localizable", "restoreInfo.noteInfo", fallback: "During the initial sync your funds cannot be sent or spent. Depending on the age of your wallet, it may take a few hours to fully sync.")
    /// Your wallet has been successfully restored and is now syncing
    public static let subTitle = L10n.tr("Localizable", "restoreInfo.subTitle", fallback: "Your wallet has been successfully restored and is now syncing")
    /// Zashi needs to stay open in order to continue syncing.
    public static let tip1 = L10n.tr("Localizable", "restoreInfo.tip1", fallback: "Zashi needs to stay open in order to continue syncing.")
    /// To prevent interruption, plug your open phone into a power source.
    public static let tip2 = L10n.tr("Localizable", "restoreInfo.tip2", fallback: "To prevent interruption, plug your open phone into a power source.")
    /// Keep your open phone in a secure place.
    public static let tip3 = L10n.tr("Localizable", "restoreInfo.tip3", fallback: "Keep your open phone in a secure place.")
    /// Syncing Tips:
    public static let tips = L10n.tr("Localizable", "restoreInfo.tips", fallback: "Syncing Tips:")
    /// Keep Zashi open!
    public static let title = L10n.tr("Localizable", "restoreInfo.title", fallback: "Keep Zashi open!")
  }
  public enum Root {
    public enum Debug {
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
    public enum ExistingWallet {
      /// We identified a Zashi database backup on this device. If you create a new wallet, you will lose access to this database backup and if you try to restore later, some information may be lost.
      public static let message = L10n.tr("Localizable", "root.existingWallet.Message", fallback: "We identified a Zashi database backup on this device. If you create a new wallet, you will lose access to this database backup and if you try to restore later, some information may be lost.")
      /// Restore
      public static let restore = L10n.tr("Localizable", "root.existingWallet.restore", fallback: "Restore")
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
    public enum SeedPhrase {
      public enum DifferentSeed {
        /// This recovery phrase doesn't match the Zashi database backup saved on this device. If you proceed, you will lose access to this database backup and if you try to restore later, some information may be lost.
        public static let message = L10n.tr("Localizable", "root.seedPhrase.differentSeed.message", fallback: "This recovery phrase doesn't match the Zashi database backup saved on this device. If you proceed, you will lose access to this database backup and if you try to restore later, some information may be lost.")
        /// Try Again
        public static let tryAgain = L10n.tr("Localizable", "root.seedPhrase.differentSeed.tryAgain", fallback: "Try Again")
      }
    }
    public enum ServiceUnavailable {
      /// Your current server is experiencing difficulties. Check your device connection, and/or navigate to Advanced Settings to choose a different server.
      public static let message = L10n.tr("Localizable", "root.serviceUnavailable.Message", fallback: "Your current server is experiencing difficulties. Check your device connection, and/or navigate to Advanced Settings to choose a different server.")
      /// Switch server
      public static let switchServer = L10n.tr("Localizable", "root.serviceUnavailable.switchServer", fallback: "Switch server")
    }
  }
  public enum Scan {
    /// The camera is not authorized. Please go to the system settings of Zashi and turn it on.
    public static let cameraSettings = L10n.tr("Localizable", "scan.cameraSettings", fallback: "The camera is not authorized. Please go to the system settings of Zashi and turn it on.")
    /// This image doesn't hold a valid Zcash address.
    public static let invalidImage = L10n.tr("Localizable", "scan.invalidImage", fallback: "This image doesn't hold a valid Zcash address.")
    /// This QR code doesn't hold a valid Zcash address.
    public static let invalidQR = L10n.tr("Localizable", "scan.invalidQR", fallback: "This QR code doesn't hold a valid Zcash address.")
    /// Open settings
    public static let openSettings = L10n.tr("Localizable", "scan.openSettings", fallback: "Open settings")
    /// This image holds several valid Zcash addresses.
    public static let severalCodesFound = L10n.tr("Localizable", "scan.severalCodesFound", fallback: "This image holds several valid Zcash addresses.")
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
    /// Address not in Address Book
    public static let addressNotInBook = L10n.tr("Localizable", "send.addressNotInBook", fallback: "Address not in Address Book")
    /// Zcash Address
    public static let addressPlaceholder = L10n.tr("Localizable", "send.addressPlaceholder", fallback: "Zcash Address")
    /// Amount
    public static let amount = L10n.tr("Localizable", "send.amount", fallback: "Amount")
    /// Total Amount
    public static let amountSummary = L10n.tr("Localizable", "send.amountSummary", fallback: "Total Amount")
    /// Confirmation
    public static let confirmationTitle = L10n.tr("Localizable", "send.confirmationTitle", fallback: "Confirmation")
    /// USD
    public static let currencyPlaceholder = L10n.tr("Localizable", "send.currencyPlaceholder", fallback: "USD")
    /// Fee
    public static let feeSummary = L10n.tr("Localizable", "send.feeSummary", fallback: "Fee")
    /// Cancel
    public static let goBack = L10n.tr("Localizable", "send.goBack", fallback: "Cancel")
    /// Write encrypted message here...
    public static let memoPlaceholder = L10n.tr("Localizable", "send.memoPlaceholder", fallback: "Write encrypted message here...")
    /// Message
    public static let message = L10n.tr("Localizable", "send.message", fallback: "Message")
    /// Review
    public static let review = L10n.tr("Localizable", "send.review", fallback: "Review")
    /// Sending
    public static let sending = L10n.tr("Localizable", "send.sending", fallback: "Sending")
    /// Send to
    public static let to = L10n.tr("Localizable", "send.to", fallback: "Send to")
    /// Sending to
    public static let toSummary = L10n.tr("Localizable", "send.toSummary", fallback: "Sending to")
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
    public enum Info {
      /// Transparent transactions can’t have memos
      public static let memo = L10n.tr("Localizable", "send.info.memo", fallback: "Transparent transactions can’t have memos")
    }
  }
  public enum ServerSetup {
    /// Active
    public static let active = L10n.tr("Localizable", "serverSetup.active", fallback: "Active")
    /// Browse all servers
    public static let allServers = L10n.tr("Localizable", "serverSetup.allServers", fallback: "Browse all servers")
    /// This may take a moment...
    public static let couldTakeTime = L10n.tr("Localizable", "serverSetup.couldTakeTime", fallback: "This may take a moment...")
    /// custom server
    public static let custom = L10n.tr("Localizable", "serverSetup.custom", fallback: "custom server")
    /// Default
    public static let `default` = L10n.tr("Localizable", "serverSetup.default", fallback: "Default")
    /// Fastest servers
    public static let fastestServers = L10n.tr("Localizable", "serverSetup.fastestServers", fallback: "Fastest servers")
    /// Other servers
    public static let otherServers = L10n.tr("Localizable", "serverSetup.otherServers", fallback: "Other servers")
    /// Performing Server Test
    public static let performingTest = L10n.tr("Localizable", "serverSetup.performingTest", fallback: "Performing Server Test")
    /// <hostname>:<port>
    public static let placeholder = L10n.tr("Localizable", "serverSetup.placeholder", fallback: "<hostname>:<port>")
    /// Refresh
    public static let refresh = L10n.tr("Localizable", "serverSetup.refresh", fallback: "Refresh")
    /// Save selection
    public static let save = L10n.tr("Localizable", "serverSetup.save", fallback: "Save selection")
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
    /// About Us
    public static let about = L10n.tr("Localizable", "settings.about", fallback: "About Us")
    /// Address Book
    public static let addressBook = L10n.tr("Localizable", "settings.addressBook", fallback: "Address Book")
    /// Advanced Settings
    public static let advanced = L10n.tr("Localizable", "settings.advanced", fallback: "Advanced Settings")
    /// Buy ZEC with Coinbase
    public static let buyZecCB = L10n.tr("Localizable", "settings.buyZecCB", fallback: "Buy ZEC with Coinbase")
    /// Choose a Server
    public static let chooseServer = L10n.tr("Localizable", "settings.chooseServer", fallback: "Choose a Server")
    /// A hassle-free way to buy ZEC and get it directly into your Zashi wallet.
    public static let coinbaseDesc = L10n.tr("Localizable", "settings.coinbaseDesc", fallback: "A hassle-free way to buy ZEC and get it directly into your Zashi wallet.")
    /// Currency Conversion
    public static let currencyConversion = L10n.tr("Localizable", "settings.currencyConversion", fallback: "Currency Conversion")
    /// Delete Zashi
    public static let deleteZashi = L10n.tr("Localizable", "settings.deleteZashi", fallback: "Delete Zashi")
    /// You will be asked to confirm on the next screen
    public static let deleteZashiWarning = L10n.tr("Localizable", "settings.deleteZashiWarning", fallback: "You will be asked to confirm on the next screen")
    /// Export logs only
    public static let exportLogsOnly = L10n.tr("Localizable", "settings.exportLogsOnly", fallback: "Export logs only")
    /// Export Private Data
    public static let exportPrivateData = L10n.tr("Localizable", "settings.exportPrivateData", fallback: "Export Private Data")
    /// Send Us Feedback
    public static let feedback = L10n.tr("Localizable", "settings.feedback", fallback: "Send Us Feedback")
    /// Pay with Flexa
    public static let flexa = L10n.tr("Localizable", "settings.flexa", fallback: "Pay with Flexa")
    /// Pay with Flexa payment clips and explore a new way of spending Zcash.
    public static let flexaDesc = L10n.tr("Localizable", "settings.flexaDesc", fallback: "Pay with Flexa payment clips and explore a new way of spending Zcash.")
    /// Integrations
    public static let integrations = L10n.tr("Localizable", "settings.integrations", fallback: "Integrations")
    /// Recovery Phrase
    public static let recoveryPhrase = L10n.tr("Localizable", "settings.recoveryPhrase", fallback: "Recovery Phrase")
    /// During the Restore process, it is not possible to use payment integrations.
    public static let restoreWarning = L10n.tr("Localizable", "settings.restoreWarning", fallback: "During the Restore process, it is not possible to use payment integrations.")
    /// Settings
    public static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    /// Version %@ (%@)
    public static func version(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
    }
    public enum Alert {
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
    public enum Alert {
      /// Error
      public static let title = L10n.tr("Localizable", "sync.alert.title", fallback: "Error")
    }
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
  public enum Tooltip {
    public enum ExchangeRate {
      /// We tried but we couldn’t refresh the exchange rate for you. Check your connection, relaunch the app, and we’ll try again.
      public static let desc = L10n.tr("Localizable", "tooltip.exchangeRate.desc", fallback: "We tried but we couldn’t refresh the exchange rate for you. Check your connection, relaunch the app, and we’ll try again.")
      /// Exchange rate unavailable
      public static let title = L10n.tr("Localizable", "tooltip.exchangeRate.title", fallback: "Exchange rate unavailable")
    }
  }
  public enum Transaction {
    /// Receive failed
    public static let failedReceive = L10n.tr("Localizable", "transaction.failedReceive", fallback: "Receive failed")
    /// Send failed
    public static let failedSend = L10n.tr("Localizable", "transaction.failedSend", fallback: "Send failed")
    /// Shielded Funds Failed
    public static let failedShieldedFunds = L10n.tr("Localizable", "transaction.failedShieldedFunds", fallback: "Shielded Funds Failed")
    /// Received
    public static let received = L10n.tr("Localizable", "transaction.received", fallback: "Received")
    /// Receiving...
    public static let receiving = L10n.tr("Localizable", "transaction.receiving", fallback: "Receiving...")
    /// Save address
    public static let saveAddress = L10n.tr("Localizable", "transaction.saveAddress", fallback: "Save address")
    /// Sending...
    public static let sending = L10n.tr("Localizable", "transaction.sending", fallback: "Sending...")
    /// Sent
    public static let sent = L10n.tr("Localizable", "transaction.sent", fallback: "Sent")
    /// Shielded Funds
    public static let shieldedFunds = L10n.tr("Localizable", "transaction.shieldedFunds", fallback: "Shielded Funds")
    /// Shielding Funds
    public static let shieldingFunds = L10n.tr("Localizable", "transaction.shieldingFunds", fallback: "Shielding Funds")
  }
  public enum TransactionList {
    /// Collapse transaction
    public static let collapse = L10n.tr("Localizable", "transactionList.collapse", fallback: "Collapse transaction")
    /// Message
    public static let messageTitle = L10n.tr("Localizable", "transactionList.messageTitle", fallback: "Message")
    /// Messages
    public static let messageTitlePlural = L10n.tr("Localizable", "transactionList.messageTitlePlural", fallback: "Messages")
    /// No message included in transaction
    public static let noMessageIncluded = L10n.tr("Localizable", "transactionList.noMessageIncluded", fallback: "No message included in transaction")
    /// No transaction history
    public static let noTransactions = L10n.tr("Localizable", "transactionList.noTransactions", fallback: "No transaction history")
    /// Transaction Fee
    public static let transactionFee = L10n.tr("Localizable", "transactionList.transactionFee", fallback: "Transaction Fee")
    /// Transaction ID
    public static let transactionId = L10n.tr("Localizable", "transactionList.transactionId", fallback: "Transaction ID")
  }
  public enum WalletStatus {
    /// DISCONNECTED…
    public static let disconnected = L10n.tr("Localizable", "walletStatus.disconnected", fallback: "DISCONNECTED…")
    /// RESTORING YOUR WALLET…
    public static let restoringWallet = L10n.tr("Localizable", "walletStatus.restoringWallet", fallback: "RESTORING YOUR WALLET…")
  }
  public enum WhatsNew {
    /// Zashi Version %@
    public static func version(_ p1: Any) -> String {
      return L10n.tr("Localizable", "whatsNew.version", String(describing: p1), fallback: "Zashi Version %@")
    }
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
