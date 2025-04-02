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
    /// Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.
    public static let additionalInfo = L10n.tr("Localizable", "about.additionalInfo", fallback: "Built by Zcashers, for Zcashers. Developed and maintained by Electric Coin Co., the inventor of Zcash, Zashi features a built-in user-feedback mechanism to enable more features, more quickly.")
    /// Send and receive ZEC on Zashi! Zashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private.
    public static let info = L10n.tr("Localizable", "about.info", fallback: "Send and receive ZEC on Zashi! Zashi is a minimal-design, self-custody, ZEC-only shielded wallet that keeps your transaction history and wallet balance private.")
    /// Privacy Policy
    public static let privacyPolicy = L10n.tr("Localizable", "about.privacyPolicy", fallback: "Privacy Policy")
    /// Introducing Zashi
    public static let title = L10n.tr("Localizable", "about.title", fallback: "Introducing Zashi")
  }
  public enum Accounts {
    /// Keystone
    public static let keystone = L10n.tr("Localizable", "accounts.keystone", fallback: "Keystone")
    /// Sending from
    public static let sendingFrom = L10n.tr("Localizable", "accounts.sendingFrom", fallback: "Sending from")
    /// Zashi
    public static let zashi = L10n.tr("Localizable", "accounts.zashi", fallback: "Zashi")
    public enum AddressBook {
      /// Address Book Contacts
      public static let contacts = L10n.tr("Localizable", "accounts.addressBook.contacts", fallback: "Address Book Contacts")
      /// Your Wallets
      public static let your = L10n.tr("Localizable", "accounts.addressBook.your", fallback: "Your Wallets")
    }
    public enum Keystone {
      /// Keystone Shielded Address
      public static let shieldedAddress = L10n.tr("Localizable", "accounts.keystone.shieldedAddress", fallback: "Keystone Shielded Address")
      /// Keystone Transparent Address
      public static let transparentAddress = L10n.tr("Localizable", "accounts.keystone.transparentAddress", fallback: "Keystone Transparent Address")
    }
    public enum Zashi {
      /// Zashi Shielded Address
      public static let shieldedAddress = L10n.tr("Localizable", "accounts.zashi.shieldedAddress", fallback: "Zashi Shielded Address")
      /// Zashi Transparent Address
      public static let transparentAddress = L10n.tr("Localizable", "accounts.zashi.transparentAddress", fallback: "Zashi Transparent Address")
    }
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
    /// Copy Address
    public static let copyAddress = L10n.tr("Localizable", "addressDetails.copyAddress", fallback: "Copy Address")
    /// Hi, scan this QR code to send me a ZEC payment!
    public static let shareDesc = L10n.tr("Localizable", "addressDetails.shareDesc", fallback: "Hi, scan this QR code to send me a ZEC payment!")
    /// Share QR Code
    public static let shareQR = L10n.tr("Localizable", "addressDetails.shareQR", fallback: "Share QR Code")
    /// My Zashi ZEC Address
    public static let shareTitle = L10n.tr("Localizable", "addressDetails.shareTitle", fallback: "My Zashi ZEC Address")
  }
  public enum Annotation {
    /// Add note
    public static let add = L10n.tr("Localizable", "annotation.add", fallback: "Add note")
    /// Add a note
    public static let addArticle = L10n.tr("Localizable", "annotation.addArticle", fallback: "Add a note")
    /// %@/%@ characters
    public static func chars(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "annotation.chars", String(describing: p1), String(describing: p2), fallback: "%@/%@ characters")
    }
    /// Delete note
    public static let delete = L10n.tr("Localizable", "annotation.delete", fallback: "Delete note")
    /// Edit a note
    public static let edit = L10n.tr("Localizable", "annotation.edit", fallback: "Edit a note")
    /// Write an optional note to describe this transaction...
    public static let placeholder = L10n.tr("Localizable", "annotation.placeholder", fallback: "Write an optional note to describe this transaction...")
    /// Save note
    public static let save = L10n.tr("Localizable", "annotation.save", fallback: "Save note")
    /// Note
    public static let title = L10n.tr("Localizable", "annotation.title", fallback: "Note")
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
    /// Shielding
    public static let shieldingInProgress = L10n.tr("Localizable", "balances.shieldingInProgress", fallback: "Shielding")
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
  public enum Component {
    /// Low Privacy
    public static let lowPrivacy = L10n.tr("Localizable", "component.lowPrivacy", fallback: "Low Privacy")
    /// Maximum Privacy
    public static let maxPrivacy = L10n.tr("Localizable", "component.maxPrivacy", fallback: "Maximum Privacy")
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
  public enum DeeplinkWarning {
    /// Rescan in Zashi
    public static let cta = L10n.tr("Localizable", "deeplinkWarning.cta", fallback: "Rescan in Zashi")
    /// For better safety and security, rescan the QR code with Zashi.
    public static let desc = L10n.tr("Localizable", "deeplinkWarning.desc", fallback: "For better safety and security, rescan the QR code with Zashi.")
    /// Hello!
    public static let screenTitle = L10n.tr("Localizable", "deeplinkWarning.screenTitle", fallback: "Hello!")
    /// Looks like you used a third-party app to scan for payment.
    public static let title = L10n.tr("Localizable", "deeplinkWarning.title", fallback: "Looks like you used a third-party app to scan for payment.")
  }
  public enum DeleteWallet {
    /// Reset Zashi
    public static let actionButtonTitle = L10n.tr("Localizable", "deleteWallet.actionButtonTitle", fallback: "Reset Zashi")
    /// I understand
    public static let iUnderstand = L10n.tr("Localizable", "deleteWallet.iUnderstand", fallback: "I understand")
    /// Resetting your app can lead to complete loss of access to your funds! ⚠️
    public static let message1 = L10n.tr("Localizable", "deleteWallet.message1", fallback: "Resetting your app can lead to complete loss of access to your funds! ⚠️")
    /// Make sure you have both your secret recovery phrase and wallet birthday height saved before you proceed.
    public static let message2 = L10n.tr("Localizable", "deleteWallet.message2", fallback: "Make sure you have both your secret recovery phrase and wallet birthday height saved before you proceed.")
    /// Resetting the Zashi app will delete the app database and cached app data, and disconnect all connected hardware wallets.
    public static let message3 = L10n.tr("Localizable", "deleteWallet.message3", fallback: "Resetting the Zashi app will delete the app database and cached app data, and disconnect all connected hardware wallets.")
    /// Once you Reset Zashi, the only way to access your funds is through a wallet restore process that requires your Zashi Recovery Phrase and Wallet Birthday Height.
    public static let message4 = L10n.tr("Localizable", "deleteWallet.message4", fallback: "Once you Reset Zashi, the only way to access your funds is through a wallet restore process that requires your Zashi Recovery Phrase and Wallet Birthday Height.")
    /// Reset
    public static let screenTitle = L10n.tr("Localizable", "deleteWallet.screenTitle", fallback: "Reset")
    /// Reset Zashi
    public static let title = L10n.tr("Localizable", "deleteWallet.title", fallback: "Reset Zashi")
  }
  public enum ErrorPage {
    public enum Action {
      /// Contact Support
      public static let contactSupport = L10n.tr("Localizable", "errorPage.action.contactSupport", fallback: "Contact Support")
    }
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
  public enum Filter {
    /// Apply
    public static let apply = L10n.tr("Localizable", "filter.apply", fallback: "Apply")
    /// at
    public static let at = L10n.tr("Localizable", "filter.at", fallback: "at")
    /// Bookmarked
    public static let bookmarked = L10n.tr("Localizable", "filter.bookmarked", fallback: "Bookmarked")
    /// Contact
    public static let contact = L10n.tr("Localizable", "filter.contact", fallback: "Contact")
    /// %@ days ago
    public static func daysAgo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "filter.daysAgo", String(describing: p1), fallback: "%@ days ago")
    }
    /// Memos
    public static let memos = L10n.tr("Localizable", "filter.memos", fallback: "Memos")
    /// No results
    public static let noResults = L10n.tr("Localizable", "filter.noResults", fallback: "No results")
    /// Notes
    public static let notes = L10n.tr("Localizable", "filter.notes", fallback: "Notes")
    /// Previous 30 days
    public static let previous30days = L10n.tr("Localizable", "filter.previous30days", fallback: "Previous 30 days")
    /// Previous 7 days
    public static let previous7days = L10n.tr("Localizable", "filter.previous7days", fallback: "Previous 7 days")
    /// Received
    public static let received = L10n.tr("Localizable", "filter.received", fallback: "Received")
    /// Reset
    public static let reset = L10n.tr("Localizable", "filter.reset", fallback: "Reset")
    /// Search
    public static let search = L10n.tr("Localizable", "filter.search", fallback: "Search")
    /// Sent
    public static let sent = L10n.tr("Localizable", "filter.sent", fallback: "Sent")
    /// Filter
    public static let title = L10n.tr("Localizable", "filter.title", fallback: "Filter")
    /// Today
    public static let today = L10n.tr("Localizable", "filter.today", fallback: "Today")
    /// We tried but couldn’t find anything.
    public static let weTried = L10n.tr("Localizable", "filter.weTried", fallback: "We tried but couldn’t find anything.")
    /// Yesterday
    public static let yesterday = L10n.tr("Localizable", "filter.yesterday", fallback: "Yesterday")
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
    /// Copied to the clipboard!
    public static let copiedToTheClipboard = L10n.tr("Localizable", "general.copiedToTheClipboard", fallback: "Copied to the clipboard!")
    /// Delete
    public static let delete = L10n.tr("Localizable", "general.delete", fallback: "Delete")
    /// Done
    public static let done = L10n.tr("Localizable", "general.done", fallback: "Done")
    /// Typical Fee < %@
    public static func fee(_ p1: Any) -> String {
      return L10n.tr("Localizable", "general.fee", String(describing: p1), fallback: "Typical Fee < %@")
    }
    /// < %@
    public static func feeShort(_ p1: Any) -> String {
      return L10n.tr("Localizable", "general.feeShort", String(describing: p1), fallback: "< %@")
    }
    /// Hide
    public static let hide = L10n.tr("Localizable", "general.hide", fallback: "Hide")
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
    /// Request
    public static let request = L10n.tr("Localizable", "general.request", fallback: "Request")
    /// Save
    public static let save = L10n.tr("Localizable", "general.save", fallback: "Save")
    /// Send
    public static let send = L10n.tr("Localizable", "general.send", fallback: "Send")
    /// Share
    public static let share = L10n.tr("Localizable", "general.share", fallback: "Share")
    /// Show
    public static let show = L10n.tr("Localizable", "general.show", fallback: "Show")
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
  public enum HomeScreen {
    /// More
    public static let more = L10n.tr("Localizable", "homeScreen.more", fallback: "More")
    /// Scan
    public static let scan = L10n.tr("Localizable", "homeScreen.scan", fallback: "Scan")
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
  public enum Integrations {
    /// Zashi integrations provide access to third party services. Features and information shared with them are outside of our control and subject to their privacy policies.
    public static let info = L10n.tr("Localizable", "integrations.info", fallback: "Zashi integrations provide access to third party services. Features and information shared with them are outside of our control and subject to their privacy policies.")
  }
  public enum Keystone {
    /// Confirm with Keystone
    public static let confirm = L10n.tr("Localizable", "keystone.confirm", fallback: "Confirm with Keystone")
    /// Connect Hardware Wallet
    public static let connect = L10n.tr("Localizable", "keystone.connect", fallback: "Connect Hardware Wallet")
    /// Scan Keystone wallet QR code
    public static let scanInfo = L10n.tr("Localizable", "keystone.scanInfo", fallback: "Scan Keystone wallet QR code")
    /// Scan Keystone QR code to sign the transaction
    public static let scanInfoTransaction = L10n.tr("Localizable", "keystone.scanInfoTransaction", fallback: "Scan Keystone QR code to sign the transaction")
    /// Switch from Keystone to Zashi to use Integrations.
    public static let settings = L10n.tr("Localizable", "keystone.settings", fallback: "Switch from Keystone to Zashi to use Integrations.")
    /// Keystone Wallet
    public static let wallet = L10n.tr("Localizable", "keystone.wallet", fallback: "Keystone Wallet")
    public enum AddHWWallet {
      /// Connect
      public static let connect = L10n.tr("Localizable", "keystone.addHWWallet.connect", fallback: "Connect")
      /// Select the wallet you'd like to connect to proceed. Once connected, you’ll be able to wirelessly sign transactions with your hardware wallet.
      public static let desc = L10n.tr("Localizable", "keystone.addHWWallet.desc", fallback: "Select the wallet you'd like to connect to proceed. Once connected, you’ll be able to wirelessly sign transactions with your hardware wallet.")
      /// Forget this device
      public static let forgetDevice = L10n.tr("Localizable", "keystone.addHWWallet.forgetDevice", fallback: "Forget this device")
      /// Instructions:
      public static let howTo = L10n.tr("Localizable", "keystone.addHWWallet.howTo", fallback: "Instructions:")
      /// Ready to Scan
      public static let readyToScan = L10n.tr("Localizable", "keystone.addHWWallet.readyToScan", fallback: "Ready to Scan")
      /// Scan your device’s QR code to connect.
      public static let scan = L10n.tr("Localizable", "keystone.addHWWallet.scan", fallback: "Scan your device’s QR code to connect.")
      /// Unlock your Keystone
      public static let step1 = L10n.tr("Localizable", "keystone.addHWWallet.step1", fallback: "Unlock your Keystone")
      /// Tap the menu icon
      public static let step2 = L10n.tr("Localizable", "keystone.addHWWallet.step2", fallback: "Tap the menu icon")
      /// Tap on Connect Software Wallet
      public static let step3 = L10n.tr("Localizable", "keystone.addHWWallet.step3", fallback: "Tap on Connect Software Wallet")
      /// Select Zashi app and scan QR code
      public static let step4 = L10n.tr("Localizable", "keystone.addHWWallet.step4", fallback: "Select Zashi app and scan QR code")
      /// Confirm Account to Access
      public static let title = L10n.tr("Localizable", "keystone.addHWWallet.title", fallback: "Confirm Account to Access")
      /// View Keystone tutorial
      public static let tutorial = L10n.tr("Localizable", "keystone.addHWWallet.tutorial", fallback: "View Keystone tutorial")
    }
    public enum Drawer {
      /// Wallets & Hardware
      public static let title = L10n.tr("Localizable", "keystone.drawer.title", fallback: "Wallets & Hardware")
      public enum Banner {
        /// Get 5%% off airgapped hardware wallet. Promo code "Zashi".
        public static let desc = L10n.tr("Localizable", "keystone.drawer.banner.desc", fallback: "Get 5%% off airgapped hardware wallet. Promo code \"Zashi\".")
        /// Keystone Hardware Wallet
        public static let title = L10n.tr("Localizable", "keystone.drawer.banner.title", fallback: "Keystone Hardware Wallet")
      }
    }
    public enum SignWith {
      /// After you have signed with Keystone, tap on the Get Signature button below.
      public static let desc = L10n.tr("Localizable", "keystone.signWith.desc", fallback: "After you have signed with Keystone, tap on the Get Signature button below.")
      /// Get Signature
      public static let getSignature = L10n.tr("Localizable", "keystone.signWith.getSignature", fallback: "Get Signature")
      /// Hardware
      public static let hardware = L10n.tr("Localizable", "keystone.signWith.hardware", fallback: "Hardware")
      /// Reject
      public static let reject = L10n.tr("Localizable", "keystone.signWith.reject", fallback: "Reject")
      /// Sign Transaction
      public static let signTransaction = L10n.tr("Localizable", "keystone.signWith.signTransaction", fallback: "Sign Transaction")
      /// Scan with your Keystone wallet
      public static let title = L10n.tr("Localizable", "keystone.signWith.title", fallback: "Scan with your Keystone wallet")
    }
  }
  public enum KeystoneTransactionReject {
    /// Go back
    public static let goBack = L10n.tr("Localizable", "keystoneTransactionReject.goBack", fallback: "Go back")
    /// Rejecting the signature will cancel the transaction, and you’ll need to start over if you want to proceed.
    public static let msg = L10n.tr("Localizable", "keystoneTransactionReject.msg", fallback: "Rejecting the signature will cancel the transaction, and you’ll need to start over if you want to proceed.")
    /// Reject Signature
    public static let rejectSig = L10n.tr("Localizable", "keystoneTransactionReject.rejectSig", fallback: "Reject Signature")
    /// Are you sure?
    public static let title = L10n.tr("Localizable", "keystoneTransactionReject.title", fallback: "Are you sure?")
  }
  public enum LocalAuthentication {
    /// The Following content requires authentication.
    public static let reason = L10n.tr("Localizable", "localAuthentication.reason", fallback: "The Following content requires authentication.")
  }
  public enum MessageEditor {
    /// Reply-to: Include my address in the memo
    public static let addUA = L10n.tr("Localizable", "messageEditor.addUA", fallback: "Reply-to: Include my address in the memo")
    /// 
    /// >>> reply-to: %@
    public static func addUAformat(_ p1: Any) -> String {
      return L10n.tr("Localizable", "messageEditor.addUAformat", String(describing: p1), fallback: "\n>>> reply-to: %@")
    }
    /// Your address is included in the memo
    public static let removeUA = L10n.tr("Localizable", "messageEditor.removeUA", fallback: "Your address is included in the memo")
  }
  public enum More {
    /// More Options
    public static let options = L10n.tr("Localizable", "more.options", fallback: "More Options")
  }
  public enum NotEnoughFreeSpace {
    /// %@ MB available. 
    public static func dataAvailable(_ p1: Any) -> String {
      return L10n.tr("Localizable", "notEnoughFreeSpace.dataAvailable", String(describing: p1), fallback: "%@ MB available. ")
    }
    /// Syncing will stay paused until more space is available.
    public static let messagePost = L10n.tr("Localizable", "notEnoughFreeSpace.messagePost", fallback: "Syncing will stay paused until more space is available.")
    /// Zashi requires %@ GB of space to synchronize the Zcash blockchain but there is only 
    public static func messagePre(_ p1: Any) -> String {
      return L10n.tr("Localizable", "notEnoughFreeSpace.messagePre", String(describing: p1), fallback: "Zashi requires %@ GB of space to synchronize the Zcash blockchain but there is only ")
    }
    /// ~%@ MB of additional space required to continue
    public static func requiredSpace(_ p1: Any) -> String {
      return L10n.tr("Localizable", "notEnoughFreeSpace.requiredSpace", String(describing: p1), fallback: "~%@ MB of additional space required to continue")
    }
    /// Not enough free space
    public static let title = L10n.tr("Localizable", "notEnoughFreeSpace.title", fallback: "Not enough free space")
  }
  public enum OsStatusError {
    /// Error code: %@
    public static func error(_ p1: Any) -> String {
      return L10n.tr("Localizable", "osStatusError.error", String(describing: p1), fallback: "Error code: %@")
    }
    /// Your funds are safe but something happened while we were trying to retrieve the Keychain data. Close the Zashi app, and give it a fresh launch, we will try again.
    public static let message = L10n.tr("Localizable", "osStatusError.message", fallback: "Your funds are safe but something happened while we were trying to retrieve the Keychain data. Close the Zashi app, and give it a fresh launch, we will try again.")
    /// It’s not you, it’s us.
    public static let title = L10n.tr("Localizable", "osStatusError.title", fallback: "It’s not you, it’s us.")
  }
  public enum Partners {
    /// https://pay.coinbase.com/buy/select-asset?appId=%@&addresses={"%@":["zcash"]}
    public static func coinbaseOnrampUrl(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "partners.coinbaseOnrampUrl", String(describing: p1), String(describing: p2), fallback: "https://pay.coinbase.com/buy/select-asset?appId=%@&addresses={\"%@\":[\"zcash\"]}")
    }
    public enum Flexa {
      /// We're sorry but something has failed. Please try again.
      public static let transactionFailedMessage = L10n.tr("Localizable", "partners.flexa.transactionFailedMessage", fallback: "We're sorry but something has failed. Please try again.")
      /// Transaction Failed
      public static let transactionFailedTitle = L10n.tr("Localizable", "partners.flexa.transactionFailedTitle", fallback: "Transaction Failed")
    }
  }
  public enum PlainOnboarding {
    /// A Zcash (ZEC) wallet built for private payments
    public static let title = L10n.tr("Localizable", "plainOnboarding.title", fallback: "A Zcash (ZEC) wallet built for private payments")
    public enum Button {
      /// Create new wallet
      public static let createNewWallet = L10n.tr("Localizable", "plainOnboarding.button.createNewWallet", fallback: "Create new wallet")
      /// Restore existing wallet
      public static let restoreWallet = L10n.tr("Localizable", "plainOnboarding.button.restoreWallet", fallback: "Restore existing wallet")
    }
  }
  public enum PrivateDataConsent {
    /// I agree to Zashi's Export Private Data Policies and Privacy Policy
    public static let confirmation = L10n.tr("Localizable", "privateDataConsent.confirmation", fallback: "I agree to Zashi's Export Private Data Policies and Privacy Policy")
    /// By clicking "I Agree" below, you give your consent to export all of your wallets’ private data such as the entire history of your wallet(s), including any connected hardware wallets. All private information, memos, amounts, and recipient addresses, even for your shielded activity will be exported.*
    public static let message1 = L10n.tr("Localizable", "privateDataConsent.message1", fallback: "By clicking \"I Agree\" below, you give your consent to export all of your wallets’ private data such as the entire history of your wallet(s), including any connected hardware wallets. All private information, memos, amounts, and recipient addresses, even for your shielded activity will be exported.*")
    /// The private data also gives the ability to see certain future actions you take with Zashi.
    public static let message2 = L10n.tr("Localizable", "privateDataConsent.message2", fallback: "The private data also gives the ability to see certain future actions you take with Zashi.")
    /// Sharing this private data is irrevocable - once you have shared this private data with someone, there is no way to revoke their access.
    public static let message3 = L10n.tr("Localizable", "privateDataConsent.message3", fallback: "Sharing this private data is irrevocable - once you have shared this private data with someone, there is no way to revoke their access.")
    /// *Note that this private data does not give them the ability to spend your funds, only the ability to see what you do with your funds.
    public static let message4 = L10n.tr("Localizable", "privateDataConsent.message4", fallback: "*Note that this private data does not give them the ability to spend your funds, only the ability to see what you do with your funds.")
    /// Data Export
    public static let screenTitle = L10n.tr("Localizable", "privateDataConsent.screenTitle", fallback: "Data Export")
    /// Consent for Exporting Private Data
    public static let title = L10n.tr("Localizable", "privateDataConsent.title", fallback: "Consent for Exporting Private Data")
  }
  public enum ProposalPartial {
    /// Copy transaction IDs
    public static let copyIds = L10n.tr("Localizable", "proposalPartial.copyIds", fallback: "Copy transaction IDs")
    /// Hi Zashi Team,
    public static let mailPart1 = L10n.tr("Localizable", "proposalPartial.mailPart1", fallback: "Hi Zashi Team,")
    /// While sending a transaction to a TEX address, I encountered an error state. I'm reaching out to get guidance on how to recover my funds.
    public static let mailPart2 = L10n.tr("Localizable", "proposalPartial.mailPart2", fallback: "While sending a transaction to a TEX address, I encountered an error state. I'm reaching out to get guidance on how to recover my funds.")
    /// Thank you.
    public static let mailPart3 = L10n.tr("Localizable", "proposalPartial.mailPart3", fallback: "Thank you.")
    /// TEX Transaction Error
    public static let mailSubject = L10n.tr("Localizable", "proposalPartial.mailSubject", fallback: "TEX Transaction Error")
    /// Send to this recipient required multiple transactions but only some of them succeeded and the rest failed. Your funds are safe but need to be recovered with assistance from our side.
    public static let message1 = L10n.tr("Localizable", "proposalPartial.message1", fallback: "Send to this recipient required multiple transactions but only some of them succeeded and the rest failed. Your funds are safe but need to be recovered with assistance from our side.")
    /// Please use the button below to contact us. it automatically prepares all the data we need in order to help you restore your funds.
    public static let message2 = L10n.tr("Localizable", "proposalPartial.message2", fallback: "Please use the button below to contact us. it automatically prepares all the data we need in order to help you restore your funds.")
    /// Send Failed
    public static let title = L10n.tr("Localizable", "proposalPartial.title", fallback: "Send Failed")
    /// Transaction Ids
    public static let transactionIds = L10n.tr("Localizable", "proposalPartial.transactionIds", fallback: "Transaction Ids")
    /// Transaction statuses:
    public static let transactionStatuses = L10n.tr("Localizable", "proposalPartial.transactionStatuses", fallback: "Transaction statuses:")
  }
  public enum Receive {
    /// Copy
    public static let copy = L10n.tr("Localizable", "receive.copy", fallback: "Copy")
    /// QR Code
    public static let qrCode = L10n.tr("Localizable", "receive.qrCode", fallback: "QR Code")
    /// Request
    public static let request = L10n.tr("Localizable", "receive.request", fallback: "Request")
    /// Sapling Address
    public static let sa = L10n.tr("Localizable", "receive.sa", fallback: "Sapling Address")
    /// Zcash Sapling Address
    public static let saplingAddress = L10n.tr("Localizable", "receive.saplingAddress", fallback: "Zcash Sapling Address")
    /// Transparent Address
    public static let ta = L10n.tr("Localizable", "receive.ta", fallback: "Transparent Address")
    /// Receive Zcash
    public static let title = L10n.tr("Localizable", "receive.title", fallback: "Receive Zcash")
    /// Unified Address
    public static let ua = L10n.tr("Localizable", "receive.ua", fallback: "Unified Address")
    /// Prioritize using your shielded address for maximum privacy.
    public static let warning = L10n.tr("Localizable", "receive.warning", fallback: "Prioritize using your shielded address for maximum privacy.")
    public enum Error {
      /// could not extract sapling receiver from UA
      public static let cantExtractSaplingAddress = L10n.tr("Localizable", "receive.error.cantExtractSaplingAddress", fallback: "could not extract sapling receiver from UA")
      /// could not extract transparent receiver from UA
      public static let cantExtractTransparentAddress = L10n.tr("Localizable", "receive.error.cantExtractTransparentAddress", fallback: "could not extract transparent receiver from UA")
      /// could not extract UA
      public static let cantExtractUnifiedAddress = L10n.tr("Localizable", "receive.error.cantExtractUnifiedAddress", fallback: "could not extract UA")
    }
  }
  public enum RecoveryPhraseDisplay {
    /// Wallet Birthday Height determines the birth (chain) height of your wallet and facilitates faster wallet restore process. Save this number together with your seed phrase in a safe place.
    public static let birthdayDesc = L10n.tr("Localizable", "recoveryPhraseDisplay.birthdayDesc", fallback: "Wallet Birthday Height determines the birth (chain) height of your wallet and facilitates faster wallet restore process. Save this number together with your seed phrase in a safe place.")
    /// Wallet Birthday Height
    public static let birthdayTitle = L10n.tr("Localizable", "recoveryPhraseDisplay.birthdayTitle", fallback: "Wallet Birthday Height")
    /// The following 24 words are the keys to your funds and are the only way to recover your funds if you get locked out or get a new device.
    public static let description = L10n.tr("Localizable", "recoveryPhraseDisplay.description", fallback: "The following 24 words are the keys to your funds and are the only way to recover your funds if you get locked out or get a new device.")
    /// Hide security details
    public static let hide = L10n.tr("Localizable", "recoveryPhraseDisplay.hide", fallback: "Hide security details")
    /// The keys are missing. No backup phrase is stored in the keychain.
    public static let noWords = L10n.tr("Localizable", "recoveryPhraseDisplay.noWords", fallback: "The keys are missing. No backup phrase is stored in the keychain.")
    /// Reveal security details
    public static let reveal = L10n.tr("Localizable", "recoveryPhraseDisplay.reveal", fallback: "Reveal security details")
    /// Recovery Phrase
    public static let screenTitle = L10n.tr("Localizable", "recoveryPhraseDisplay.screenTitle", fallback: "Recovery Phrase")
    /// Secure Your Zashi Wallet
    public static let title = L10n.tr("Localizable", "recoveryPhraseDisplay.title", fallback: "Secure Your Zashi Wallet")
    /// Protect your ZEC by storing this phrase in a place you trust and never share it with anyone!
    public static let warning = L10n.tr("Localizable", "recoveryPhraseDisplay.warning", fallback: "Protect your ZEC by storing this phrase in a place you trust and never share it with anyone!")
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
  public enum RequestZec {
    /// Payment Request
    public static let title = L10n.tr("Localizable", "requestZec.title", fallback: "Payment Request")
    /// What’s this for?
    public static let whatFor = L10n.tr("Localizable", "requestZec.whatFor", fallback: "What’s this for?")
    public enum Summary {
      /// Hi, I have generated a ZEC payment request for you using the Zashi app!
      public static let shareDesc = L10n.tr("Localizable", "requestZec.summary.shareDesc", fallback: "Hi, I have generated a ZEC payment request for you using the Zashi app!")
      /// (download link: https://apps.apple.com/app/zashi-zcash-wallet/id1672392439)
      public static let shareMsg = L10n.tr("Localizable", "requestZec.summary.shareMsg", fallback: "(download link: https://apps.apple.com/app/zashi-zcash-wallet/id1672392439)")
      /// Share QR Code
      public static let shareQR = L10n.tr("Localizable", "requestZec.summary.shareQR", fallback: "Share QR Code")
      /// Request ZEC
      public static let shareTitle = L10n.tr("Localizable", "requestZec.summary.shareTitle", fallback: "Request ZEC")
    }
  }
  public enum RestoreInfo {
    /// Keep screen on while restoring
    public static let checkbox = L10n.tr("Localizable", "restoreInfo.checkbox", fallback: "Keep screen on while restoring")
    /// Got it!
    public static let gotIt = L10n.tr("Localizable", "restoreInfo.gotIt", fallback: "Got it!")
    /// Note: 
    public static let note = L10n.tr("Localizable", "restoreInfo.note", fallback: "Note: ")
    /// Your funds cannot be spent with Zashi until your wallet is fully restored.
    public static let noteInfo = L10n.tr("Localizable", "restoreInfo.noteInfo", fallback: "Your funds cannot be spent with Zashi until your wallet is fully restored.")
    /// Your wallet is being restored.
    public static let subTitle = L10n.tr("Localizable", "restoreInfo.subTitle", fallback: "Your wallet is being restored.")
    /// Keep the Zashi app open on an active phone screen.
    public static let tip1 = L10n.tr("Localizable", "restoreInfo.tip1", fallback: "Keep the Zashi app open on an active phone screen.")
    /// To prevent your phone screen from going dark, turn off power-saving mode and keep your phone plugged in.
    public static let tip2 = L10n.tr("Localizable", "restoreInfo.tip2", fallback: "To prevent your phone screen from going dark, turn off power-saving mode and keep your phone plugged in.")
    /// Zashi is scanning the blockchain to retrieve your transactions. Older wallets can take hours to restore. Follow these steps to prevent interruption:
    public static let tips = L10n.tr("Localizable", "restoreInfo.tips", fallback: "Zashi is scanning the blockchain to retrieve your transactions. Older wallets can take hours to restore. Follow these steps to prevent interruption:")
    /// Keep Zashi open!
    public static let title = L10n.tr("Localizable", "restoreInfo.title", fallback: "Keep Zashi open!")
  }
  public enum RestoreWallet {
    /// Please type in your 24-word secret recovery phrase in the correct order.
    public static let info = L10n.tr("Localizable", "restoreWallet.info", fallback: "Please type in your 24-word secret recovery phrase in the correct order.")
    /// Secret Recovery Phrase
    public static let title = L10n.tr("Localizable", "restoreWallet.title", fallback: "Secret Recovery Phrase")
    public enum Birthday {
      /// Estimate my block height
      public static let estimate = L10n.tr("Localizable", "restoreWallet.birthday.estimate", fallback: "Estimate my block height")
      /// Wallet Birthday Height is the point in time when your wallet was created.
      public static let fieldInfo = L10n.tr("Localizable", "restoreWallet.birthday.fieldInfo", fallback: "Wallet Birthday Height is the point in time when your wallet was created.")
      /// Entering your Wallet Birthday Height helps speed up the restore process.
      public static let info = L10n.tr("Localizable", "restoreWallet.birthday.info", fallback: "Entering your Wallet Birthday Height helps speed up the restore process.")
      /// Enter number
      public static let placeholder = L10n.tr("Localizable", "restoreWallet.birthday.placeholder", fallback: "Enter number")
      /// Block Height
      public static let title = L10n.tr("Localizable", "restoreWallet.birthday.title", fallback: "Block Height")
      public enum EstimateDate {
        /// Entering the block height at which your wallet was created reduces the number of blocks that need to be scanned to recover your wallet.
        public static let info = L10n.tr("Localizable", "restoreWallet.birthday.estimateDate.info", fallback: "Entering the block height at which your wallet was created reduces the number of blocks that need to be scanned to recover your wallet.")
        /// First Wallet Transaction
        public static let title = L10n.tr("Localizable", "restoreWallet.birthday.estimateDate.title", fallback: "First Wallet Transaction")
        /// If you’re not sure, choose an earlier date.
        public static let warning = L10n.tr("Localizable", "restoreWallet.birthday.estimateDate.warning", fallback: "If you’re not sure, choose an earlier date.")
      }
      public enum Estimated {
        /// Zashi will scan and recover all transactions made after the following block number.
        public static let info = L10n.tr("Localizable", "restoreWallet.birthday.estimated.info", fallback: "Zashi will scan and recover all transactions made after the following block number.")
        /// Estimated Block Height
        public static let title = L10n.tr("Localizable", "restoreWallet.birthday.estimated.title", fallback: "Estimated Block Height")
      }
    }
    public enum Help {
      /// ^[The Wallet Birthday Height](style: 'boldPrimary') is the block height (block # in the blockchain) at which your wallet was created. If you ever lose access to your Zashi app and need to recover your funds, providing the block height along with your recovery phrase can significantly speed up the process.
      public static let birthday = L10n.tr("Localizable", "restoreWallet.help.birthday", fallback: "^[The Wallet Birthday Height](style: 'boldPrimary') is the block height (block # in the blockchain) at which your wallet was created. If you ever lose access to your Zashi app and need to recover your funds, providing the block height along with your recovery phrase can significantly speed up the process.")
      /// ^[The Secret Recovery Phrase](style: 'boldPrimary') is a unique set of 24 words, appearing in a precise order. It can be used to gain full control of your funds from any device via any Zcash wallet app. Think of it as the master key to your wallet. It is stored in Zashi’s Advanced Settings.
      public static let phrase = L10n.tr("Localizable", "restoreWallet.help.phrase", fallback: "^[The Secret Recovery Phrase](style: 'boldPrimary') is a unique set of 24 words, appearing in a precise order. It can be used to gain full control of your funds from any device via any Zcash wallet app. Think of it as the master key to your wallet. It is stored in Zashi’s Advanced Settings.")
      /// Need to know more?
      public static let title = L10n.tr("Localizable", "restoreWallet.help.title", fallback: "Need to know more?")
    }
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
          /// Wallet deletion only partially succeeded. Please retry to finish the resetting process.
          public static let message = L10n.tr("Localizable", "root.initialization.alert.wipeFailed.message", fallback: "Wallet deletion only partially succeeded. Please retry to finish the resetting process.")
          /// Wallet deletion failed.
          public static let title = L10n.tr("Localizable", "root.initialization.alert.wipeFailed.title", fallback: "Wallet deletion failed.")
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
  public enum Send {
    /// Add contact by tapping on Address Book icon.
    public static let addressNotInBook = L10n.tr("Localizable", "send.addressNotInBook", fallback: "Add contact by tapping on Address Book icon.")
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
    /// Unable to send
    public static let failure = L10n.tr("Localizable", "send.failure", fallback: "Unable to send")
    /// There was an error attempting to send tokens. Try it again, please.
    public static let failureInfo = L10n.tr("Localizable", "send.failureInfo", fallback: "There was an error attempting to send tokens. Try it again, please.")
    /// Unable to shield
    public static let failureShielding = L10n.tr("Localizable", "send.failureShielding", fallback: "Unable to shield")
    /// There was an error attempting to shield your tokens. Try it again, please.
    public static let failureShieldingInfo = L10n.tr("Localizable", "send.failureShieldingInfo", fallback: "There was an error attempting to shield your tokens. Try it again, please.")
    /// Fee
    public static let feeSummary = L10n.tr("Localizable", "send.feeSummary", fallback: "Fee")
    /// Cancel
    public static let goBack = L10n.tr("Localizable", "send.goBack", fallback: "Cancel")
    /// Write encrypted message here...
    public static let memoPlaceholder = L10n.tr("Localizable", "send.memoPlaceholder", fallback: "Write encrypted message here...")
    /// Message
    public static let message = L10n.tr("Localizable", "send.message", fallback: "Message")
    /// Report
    public static let report = L10n.tr("Localizable", "send.report", fallback: "Report")
    /// Connection Error
    public static let resubmission = L10n.tr("Localizable", "send.resubmission", fallback: "Connection Error")
    /// Zashi encountered connection issues when submitting the transaction. It will retry in the next few minutes.
    public static let resubmissionInfo = L10n.tr("Localizable", "send.resubmissionInfo", fallback: "Zashi encountered connection issues when submitting the transaction. It will retry in the next few minutes.")
    /// Review
    public static let review = L10n.tr("Localizable", "send.review", fallback: "Review")
    /// Sending...
    public static let sending = L10n.tr("Localizable", "send.sending", fallback: "Sending...")
    /// Your tokens are being sent to
    public static let sendingInfo = L10n.tr("Localizable", "send.sendingInfo", fallback: "Your tokens are being sent to")
    /// Shielding
    public static let shielding = L10n.tr("Localizable", "send.shielding", fallback: "Shielding")
    /// Your tokens are getting shielded
    public static let shieldingInfo = L10n.tr("Localizable", "send.shieldingInfo", fallback: "Your tokens are getting shielded")
    /// Sent!
    public static let success = L10n.tr("Localizable", "send.success", fallback: "Sent!")
    /// Your tokens were successfully sent to
    public static let successInfo = L10n.tr("Localizable", "send.successInfo", fallback: "Your tokens were successfully sent to")
    /// Shielded!
    public static let successShielding = L10n.tr("Localizable", "send.successShielding", fallback: "Shielded!")
    /// Your tokens have been successfully shielded
    public static let successShieldingInfo = L10n.tr("Localizable", "send.successShieldingInfo", fallback: "Your tokens have been successfully shielded")
    /// Send to
    public static let to = L10n.tr("Localizable", "send.to", fallback: "Send to")
    /// Sending to
    public static let toSummary = L10n.tr("Localizable", "send.toSummary", fallback: "Sending to")
    /// View Transaction
    public static let viewTransaction = L10n.tr("Localizable", "send.viewTransaction", fallback: "View Transaction")
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
    public enum RequestPayment {
      /// For:
      public static let `for` = L10n.tr("Localizable", "send.requestPayment.for", fallback: "For:")
      /// Requested By
      public static let requestedBy = L10n.tr("Localizable", "send.requestPayment.requestedBy", fallback: "Requested By")
      /// Payment Request
      public static let title = L10n.tr("Localizable", "send.requestPayment.title", fallback: "Payment Request")
      /// Total
      public static let total = L10n.tr("Localizable", "send.requestPayment.total", fallback: "Total")
    }
  }
  public enum SendFeedback {
    /// Please let us know about any problems you have had, or features you want to see in the future.
    public static let desc = L10n.tr("Localizable", "sendFeedback.desc", fallback: "Please let us know about any problems you have had, or features you want to see in the future.")
    /// I would like to ask about...
    public static let hcwhPlaceholder = L10n.tr("Localizable", "sendFeedback.hcwhPlaceholder", fallback: "I would like to ask about...")
    /// How can we help you?
    public static let howCanWeHelp = L10n.tr("Localizable", "sendFeedback.howCanWeHelp", fallback: "How can we help you?")
    /// How is your Zashi experience?
    public static let ratingQuestion = L10n.tr("Localizable", "sendFeedback.ratingQuestion", fallback: "How is your Zashi experience?")
    /// Support
    public static let screenTitle = L10n.tr("Localizable", "sendFeedback.screenTitle", fallback: "Support")
    /// Send Us Feedback
    public static let title = L10n.tr("Localizable", "sendFeedback.title", fallback: "Send Us Feedback")
    public enum Share {
      /// Zashi
      public static let desc = L10n.tr("Localizable", "sendFeedback.share.desc", fallback: "Zashi")
      /// Your device doesn’t have an Apple email set up, so we prepared this message for you to send using your preferred email client. Please send this message to:
      public static let notAppleMailInfo = L10n.tr("Localizable", "sendFeedback.share.notAppleMailInfo", fallback: "Your device doesn’t have an Apple email set up, so we prepared this message for you to send using your preferred email client. Please send this message to:")
      /// Support message
      public static let title = L10n.tr("Localizable", "sendFeedback.share.title", fallback: "Support message")
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
    /// About
    public static let about = L10n.tr("Localizable", "settings.about", fallback: "About")
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
    /// Reset Zashi
    public static let deleteZashi = L10n.tr("Localizable", "settings.deleteZashi", fallback: "Reset Zashi")
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
    /// Connect Keystone Device
    public static let keystone = L10n.tr("Localizable", "settings.keystone", fallback: "Connect Keystone Device")
    /// Pair your Keystone hardware wallet with Zashi to sign transactions.
    public static let keystoneDesc = L10n.tr("Localizable", "settings.keystoneDesc", fallback: "Pair your Keystone hardware wallet with Zashi to sign transactions.")
    /// Zashi Recovery Phrase
    public static let recoveryPhrase = L10n.tr("Localizable", "settings.recoveryPhrase", fallback: "Zashi Recovery Phrase")
    /// During the Restore process, it is not possible to use payment integrations.
    public static let restoreWarning = L10n.tr("Localizable", "settings.restoreWarning", fallback: "During the Restore process, it is not possible to use payment integrations.")
    /// Settings
    public static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    /// Version %@ (%@)
    public static func version(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
    }
    /// What's new
    public static let whatsNew = L10n.tr("Localizable", "settings.whatsNew", fallback: "What's new")
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
  public enum Splash {
    /// Tap the face icon to use Face ID and unlock it.
    public static let authFaceID = L10n.tr("Localizable", "splash.authFaceID", fallback: "Tap the face icon to use Face ID and unlock it.")
    /// Tap the key icon to enter your passcode and unlock it.
    public static let authPasscode = L10n.tr("Localizable", "splash.authPasscode", fallback: "Tap the key icon to enter your passcode and unlock it.")
    /// Your Zashi account is secured.
    public static let authTitle = L10n.tr("Localizable", "splash.authTitle", fallback: "Your Zashi account is secured.")
    /// Tap the print icon to use Touch ID and unlock it.
    public static let authTouchID = L10n.tr("Localizable", "splash.authTouchID", fallback: "Tap the print icon to use Touch ID and unlock it.")
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
  public enum TaxExport {
    /// Download your %@ transaction history from the previous calendar year in a .csv format.
    public static func desc(_ p1: Any) -> String {
      return L10n.tr("Localizable", "taxExport.desc", String(describing: p1), fallback: "Download your %@ transaction history from the previous calendar year in a .csv format.")
    }
    /// Download
    public static let download = L10n.tr("Localizable", "taxExport.download", fallback: "Download")
    /// %@_transaction_history_%@.csv
    public static func fileName(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "taxExport.fileName", String(describing: p1), String(describing: p2), fallback: "%@_transaction_history_%@.csv")
    }
    /// %@ transaction history
    public static func shareDesc(_ p1: Any) -> String {
      return L10n.tr("Localizable", "taxExport.shareDesc", String(describing: p1), fallback: "%@ transaction history")
    }
    /// Export Tax File
    public static let taxFile = L10n.tr("Localizable", "taxExport.taxFile", fallback: "Export Tax File")
    /// Data Export
    public static let title = L10n.tr("Localizable", "taxExport.title", fallback: "Data Export")
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
    /// Receiving
    public static let receiving = L10n.tr("Localizable", "transaction.receiving", fallback: "Receiving")
    /// Save address
    public static let saveAddress = L10n.tr("Localizable", "transaction.saveAddress", fallback: "Save address")
    /// Select text
    public static let selectText = L10n.tr("Localizable", "transaction.selectText", fallback: "Select text")
    /// Sending
    public static let sending = L10n.tr("Localizable", "transaction.sending", fallback: "Sending")
    /// Sent
    public static let sent = L10n.tr("Localizable", "transaction.sent", fallback: "Sent")
    /// Shielded
    public static let shieldedFunds = L10n.tr("Localizable", "transaction.shieldedFunds", fallback: "Shielded")
    /// Shielding
    public static let shieldingFunds = L10n.tr("Localizable", "transaction.shieldingFunds", fallback: "Shielding")
  }
  public enum TransactionHistory {
    /// Address
    public static let address = L10n.tr("Localizable", "transactionHistory.address", fallback: "Address")
    /// Completed
    public static let completed = L10n.tr("Localizable", "transactionHistory.completed", fallback: "Completed")
    /// 0.001
    public static let defaultFee = L10n.tr("Localizable", "transactionHistory.defaultFee", fallback: "0.001")
    /// Transaction Details
    public static let details = L10n.tr("Localizable", "transactionHistory.details", fallback: "Transaction Details")
    /// Get some ZEC
    public static let getSomeZec = L10n.tr("Localizable", "transactionHistory.getSomeZec", fallback: "Get some ZEC")
    /// Make the first move...
    public static let makeTransaction = L10n.tr("Localizable", "transactionHistory.makeTransaction", fallback: "Make the first move...")
    /// No Message
    public static let noMessage = L10n.tr("Localizable", "transactionHistory.noMessage", fallback: "No Message")
    /// There’s nothing here, yet.
    public static let nothingHere = L10n.tr("Localizable", "transactionHistory.nothingHere", fallback: "There’s nothing here, yet.")
    /// Pending
    public static let pending = L10n.tr("Localizable", "transactionHistory.pending", fallback: "Pending")
    /// Save address
    public static let saveAddress = L10n.tr("Localizable", "transactionHistory.saveAddress", fallback: "Save address")
    /// See all
    public static let seeAll = L10n.tr("Localizable", "transactionHistory.seeAll", fallback: "See all")
    /// Send again
    public static let sendAgain = L10n.tr("Localizable", "transactionHistory.sendAgain", fallback: "Send again")
    /// Sent to
    public static let sentTo = L10n.tr("Localizable", "transactionHistory.sentTo", fallback: "Sent to")
    /// %@...
    public static func threeDots(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transactionHistory.threeDots", String(describing: p1), fallback: "%@...")
    }
    /// Transactions
    public static let title = L10n.tr("Localizable", "transactionHistory.title", fallback: "Transactions")
    /// View less
    public static let viewLess = L10n.tr("Localizable", "transactionHistory.viewLess", fallback: "View less")
    /// View more
    public static let viewMore = L10n.tr("Localizable", "transactionHistory.viewMore", fallback: "View more")
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
  public enum ZecKeyboard {
    /// This transaction amount is invalid.
    public static let invalid = L10n.tr("Localizable", "zecKeyboard.invalid", fallback: "This transaction amount is invalid.")
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
