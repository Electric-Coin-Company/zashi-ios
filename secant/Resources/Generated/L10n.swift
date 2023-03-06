// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// %@ ZEC
  internal static func balance(_ p1: Any) -> String {
    return L10n.tr("Localizable", "balance", String(describing: p1), fallback: "%@ ZEC")
  }
  /// QR Code for %@
  internal static func qrCodeFor(_ p1: Any) -> String {
    return L10n.tr("Localizable", "qrCodeFor", String(describing: p1), fallback: "QR Code for %@")
  }
  internal enum AddressDetails {
    /// Sapling Address
    internal static let sa = L10n.tr("Localizable", "addressDetails.sa", fallback: "Sapling Address")
    /// Transparent Address
    internal static let ta = L10n.tr("Localizable", "addressDetails.ta", fallback: "Transparent Address")
    /// Unified Address
    internal static let ua = L10n.tr("Localizable", "addressDetails.ua", fallback: "Unified Address")
  }
  internal enum Balance {
    /// %@ ZEC Available
    internal static func available(_ p1: Any) -> String {
      return L10n.tr("Localizable", "balance.available", String(describing: p1), fallback: "%@ ZEC Available")
    }
  }
  internal enum BalanceBreakdown {
    /// Auto Shielding Threshold: %@ ZEC
    internal static func autoShieldingThreshold(_ p1: Any) -> String {
      return L10n.tr("Localizable", "balanceBreakdown.autoShieldingThreshold", String(describing: p1), fallback: "Auto Shielding Threshold: %@ ZEC")
    }
    /// Block: %@
    internal static func blockId(_ p1: Any) -> String {
      return L10n.tr("Localizable", "balanceBreakdown.blockId", String(describing: p1), fallback: "Block: %@")
    }
    /// SHIELDED ZEC (SPENDABLE)
    internal static let shieldedZec = L10n.tr("Localizable", "balanceBreakdown.shieldedZec", fallback: "SHIELDED ZEC (SPENDABLE)")
    /// TOTAL BALANCE
    internal static let totalBalance = L10n.tr("Localizable", "balanceBreakdown.totalBalance", fallback: "TOTAL BALANCE")
    /// TRANSPARENT BALANCE
    internal static let transparentBalance = L10n.tr("Localizable", "balanceBreakdown.transparentBalance", fallback: "TRANSPARENT BALANCE")
  }
  internal enum Error {
    /// possible roll back
    internal static let rollBack = L10n.tr("Localizable", "error.rollBack", fallback: "possible roll back")
  }
  internal enum General {
    /// Back
    internal static let back = L10n.tr("Localizable", "general.back", fallback: "Back")
    /// Clear
    internal static let clear = L10n.tr("Localizable", "general.clear", fallback: "Clear")
    /// Close
    internal static let close = L10n.tr("Localizable", "general.close", fallback: "Close")
    /// date not available
    internal static let dateNotAvailable = L10n.tr("Localizable", "general.dateNotAvailable", fallback: "date not available")
    /// Max
    internal static let max = L10n.tr("Localizable", "general.max", fallback: "Max")
    /// Next
    internal static let next = L10n.tr("Localizable", "general.next", fallback: "Next")
    /// Send
    internal static let send = L10n.tr("Localizable", "general.send", fallback: "Send")
    /// Skip
    internal static let skip = L10n.tr("Localizable", "general.skip", fallback: "Skip")
  }
  internal enum Home {
    /// Receive ZEC
    internal static let receiveZec = L10n.tr("Localizable", "home.receiveZec", fallback: "Receive ZEC")
    /// Send ZEC
    internal static let sendZec = L10n.tr("Localizable", "home.sendZec", fallback: "Send ZEC")
    /// Secant Wallet
    internal static let title = L10n.tr("Localizable", "home.title", fallback: "Secant Wallet")
    /// See transaction history
    internal static let transactionHistory = L10n.tr("Localizable", "home.transactionHistory", fallback: "See transaction history")
  }
  internal enum ImportWallet {
    /// Enter your secret backup seed phrase.
    internal static let description = L10n.tr("Localizable", "importWallet.description", fallback: "Enter your secret backup seed phrase.")
    /// Wallet Import
    internal static let title = L10n.tr("Localizable", "importWallet.title", fallback: "Wallet Import")
    internal enum Birthday {
      /// Do you know the wallet's creation date? This will allow a faster sync. If you don't know the wallet's birthday, don't worry!
      internal static let description = L10n.tr("Localizable", "importWallet.birthday.description", fallback: "Do you know the wallet's creation date? This will allow a faster sync. If you don't know the wallet's birthday, don't worry!")
      /// Enter birthday height
      internal static let placeholder = L10n.tr("Localizable", "importWallet.birthday.placeholder", fallback: "Enter birthday height")
    }
    internal enum Button {
      /// Import a private or viewing key
      internal static let importPrivateKey = L10n.tr("Localizable", "importWallet.button.importPrivateKey", fallback: "Import a private or viewing key")
      /// Restore wallet
      internal static let restoreWallet = L10n.tr("Localizable", "importWallet.button.restoreWallet", fallback: "Restore wallet")
    }
  }
  internal enum Nefs {
    /// Not enough space on disk to do synchronisation!
    internal static let message = L10n.tr("Localizable", "nefs.message", fallback: "Not enough space on disk to do synchronisation!")
  }
  internal enum Onboarding {
    internal enum Button {
      /// Import an Existing Wallet
      internal static let importWallet = L10n.tr("Localizable", "onboarding.button.importWallet", fallback: "Import an Existing Wallet")
      /// Create New Wallet
      internal static let newWallet = L10n.tr("Localizable", "onboarding.button.newWallet", fallback: "Create New Wallet")
    }
    internal enum Step1 {
      /// As a privacy focused wallet, we shield by default. Your wallet uses the shielded address for sending and moves transparent funds to that address automatically.
      /// 
      /// In other words, the 'privacy-please' sign is on the knob.
      internal static let description = L10n.tr("Localizable", "onboarding.step1.description", fallback: "As a privacy focused wallet, we shield by default. Your wallet uses the shielded address for sending and moves transparent funds to that address automatically.\n\nIn other words, the 'privacy-please' sign is on the knob.")
      /// Welcome!
      internal static let title = L10n.tr("Localizable", "onboarding.step1.title", fallback: "Welcome!")
    }
    internal enum Step2 {
      /// You now have a unified address that includes and up-to-date shielded address for legacy systems.
      /// 
      /// This makes your wallet friendlier, and gives you and address that you won't have to upgrade again.
      internal static let description = L10n.tr("Localizable", "onboarding.step2.description", fallback: "You now have a unified address that includes and up-to-date shielded address for legacy systems.\n\nThis makes your wallet friendlier, and gives you and address that you won't have to upgrade again.")
      /// Unified Addresses
      internal static let title = L10n.tr("Localizable", "onboarding.step2.title", fallback: "Unified Addresses")
    }
    internal enum Step3 {
      /// Due to Zcash's increased popularity, we are optimizing our syncing schemes to be faster and more efficient!
      /// 
      /// The future is fast!
      internal static let description = L10n.tr("Localizable", "onboarding.step3.description", fallback: "Due to Zcash's increased popularity, we are optimizing our syncing schemes to be faster and more efficient!\n\nThe future is fast!")
      /// And so much more...
      internal static let title = L10n.tr("Localizable", "onboarding.step3.title", fallback: "And so much more...")
    }
    internal enum Step4 {
      /// Choose between creating a new wallet and importing and existing Secret Recovery Phrase
      internal static let description = L10n.tr("Localizable", "onboarding.step4.description", fallback: "Choose between creating a new wallet and importing and existing Secret Recovery Phrase")
      /// Let's get started
      internal static let title = L10n.tr("Localizable", "onboarding.step4.title", fallback: "Let's get started")
    }
  }
  internal enum ReceiveZec {
    /// Your Address
    internal static let yourAddress = L10n.tr("Localizable", "receiveZec.yourAddress", fallback: "Your Address")
  }
  internal enum RecoveryPhraseBackupValidation {
    /// Drag the words below to match your backed-up copy.
    internal static let description = L10n.tr("Localizable", "recoveryPhraseBackupValidation.description", fallback: "Drag the words below to match your backed-up copy.")
    /// Your placed words did not match your secret recovery phrase
    internal static let failedResult = L10n.tr("Localizable", "recoveryPhraseBackupValidation.failedResult", fallback: "Your placed words did not match your secret recovery phrase")
    /// Congratulations! You validated your secret recovery phrase.
    internal static let successResult = L10n.tr("Localizable", "recoveryPhraseBackupValidation.successResult", fallback: "Congratulations! You validated your secret recovery phrase.")
    /// Verify Your Backup
    internal static let title = L10n.tr("Localizable", "recoveryPhraseBackupValidation.title", fallback: "Verify Your Backup")
  }
  internal enum RecoveryPhraseDisplay {
    /// The following 24 words represent your funds and the security used to protect them. Back them up now!
    internal static let description = L10n.tr("Localizable", "recoveryPhraseDisplay.description", fallback: "The following 24 words represent your funds and the security used to protect them. Back them up now!")
    /// Oops no words
    internal static let noWords = L10n.tr("Localizable", "recoveryPhraseDisplay.noWords", fallback: "Oops no words")
    /// Your Secret Recovery Phrase
    internal static let title = L10n.tr("Localizable", "recoveryPhraseDisplay.title", fallback: "Your Secret Recovery Phrase")
    internal enum Button {
      /// Copy To Buffer
      internal static let copyToBuffer = L10n.tr("Localizable", "recoveryPhraseDisplay.button.copyToBuffer", fallback: "Copy To Buffer")
      /// I wrote it down!
      internal static let wroteItDown = L10n.tr("Localizable", "recoveryPhraseDisplay.button.wroteItDown", fallback: "I wrote it down!")
    }
  }
  internal enum RecoveryPhraseTestPreamble {
    /// It is important to understand that you are in charge here. Great, right? YOU get to be the bank!
    internal static let paragraph1 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph1", fallback: "It is important to understand that you are in charge here. Great, right? YOU get to be the bank!")
    /// But it also means that YOU are the customer, and you need to be self-reliant.
    internal static let paragraph2 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph2", fallback: "But it also means that YOU are the customer, and you need to be self-reliant.")
    /// So how do you recover funds that you've hidden on a completely decentralized and private block-chain?
    internal static let paragraph3 = L10n.tr("Localizable", "recoveryPhraseTestPreamble.paragraph3", fallback: "So how do you recover funds that you've hidden on a completely decentralized and private block-chain?")
    /// First things first
    internal static let title = L10n.tr("Localizable", "recoveryPhraseTestPreamble.title", fallback: "First things first")
    internal enum Button {
      /// By understanding and preparing
      internal static let goNext = L10n.tr("Localizable", "recoveryPhraseTestPreamble.button.goNext", fallback: "By understanding and preparing")
    }
  }
  internal enum Scan {
    /// We will validate any Zcash URI and take you to the appropriate action.
    internal static let info = L10n.tr("Localizable", "scan.info", fallback: "We will validate any Zcash URI and take you to the appropriate action.")
    /// Scanning...
    internal static let scanning = L10n.tr("Localizable", "scan.scanning", fallback: "Scanning...")
  }
  internal enum Send {
    ///  address: %@
    internal static func address(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.address", String(describing: p1), fallback: " address: %@")
    }
    /// amount: %@
    internal static func amount(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.amount", String(describing: p1), fallback: "amount: %@")
    }
    /// Sending transaction failed
    internal static let failed = L10n.tr("Localizable", "send.failed", fallback: "Sending transaction failed")
    /// Aditional funds may be in transit
    internal static let fundsInfo = L10n.tr("Localizable", "send.fundsInfo", fallback: "Aditional funds may be in transit")
    ///  memo: %@
    internal static func memo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.memo", String(describing: p1), fallback: " memo: %@")
    }
    /// Write a private message here
    internal static let memoPlaceholder = L10n.tr("Localizable", "send.memoPlaceholder", fallback: "Write a private message here")
    /// Sending %@ ZEC to
    internal static func sendingTo(_ p1: Any) -> String {
      return L10n.tr("Localizable", "send.sendingTo", String(describing: p1), fallback: "Sending %@ ZEC to")
    }
    /// Sending transaction succeeded
    internal static let succeeded = L10n.tr("Localizable", "send.succeeded", fallback: "Sending transaction succeeded")
    /// Send Zcash
    internal static let title = L10n.tr("Localizable", "send.title", fallback: "Send Zcash")
  }
  internal enum Settings {
    /// Backup Wallet
    internal static let backupWallet = L10n.tr("Localizable", "settings.backupWallet", fallback: "Backup Wallet")
    /// Enable Crash Reporting
    internal static let crashReporting = L10n.tr("Localizable", "settings.crashReporting", fallback: "Enable Crash Reporting")
    /// Exporting...
    internal static let exporting = L10n.tr("Localizable", "settings.exporting", fallback: "Exporting...")
    /// Export & share logs
    internal static let exportLogs = L10n.tr("Localizable", "settings.exportLogs", fallback: "Export & share logs")
    /// Send us feedback!
    internal static let feedback = L10n.tr("Localizable", "settings.feedback", fallback: "Send us feedback!")
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
  }
  internal enum Transaction {
    /// Confirmed
    internal static let confirmed = L10n.tr("Localizable", "transaction.confirmed", fallback: "Confirmed")
    /// %@ times
    internal static func confirmedTimes(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.confirmedTimes", String(describing: p1), fallback: "%@ times")
    }
    /// Confirming ~%@mins
    internal static func confirming(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.confirming", String(describing: p1), fallback: "Confirming ~%@mins")
    }
    /// Failed
    internal static let failed = L10n.tr("Localizable", "transaction.failed", fallback: "Failed")
    /// from
    internal static let from = L10n.tr("Localizable", "transaction.from", fallback: "from")
    /// PENDING
    internal static let pending = L10n.tr("Localizable", "transaction.pending", fallback: "PENDING")
    /// Received
    internal static let received = L10n.tr("Localizable", "transaction.received", fallback: "Received")
    /// Sending
    internal static let sending = L10n.tr("Localizable", "transaction.sending", fallback: "Sending")
    /// Sent
    internal static let sent = L10n.tr("Localizable", "transaction.sent", fallback: "Sent")
    /// to
    internal static let to = L10n.tr("Localizable", "transaction.to", fallback: "to")
    /// unconfirmed
    internal static let unconfirmed = L10n.tr("Localizable", "transaction.unconfirmed", fallback: "unconfirmed")
    /// With memo:
    internal static let withMemo = L10n.tr("Localizable", "transaction.withMemo", fallback: "With memo:")
    /// You are sending %@ ZEC
    internal static func youAreSending(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.youAreSending", String(describing: p1), fallback: "You are sending %@ ZEC")
    }
    /// You DID NOT send %@ ZEC
    internal static func youDidNotSent(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.youDidNotSent", String(describing: p1), fallback: "You DID NOT send %@ ZEC")
    }
    /// You received %@ ZEC
    internal static func youReceived(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.youReceived", String(describing: p1), fallback: "You received %@ ZEC")
    }
    /// You sent %@ ZEC
    internal static func youSent(_ p1: Any) -> String {
      return L10n.tr("Localizable", "transaction.youSent", String(describing: p1), fallback: "You sent %@ ZEC")
    }
  }
  internal enum TransactionDetail {
    /// Transaction detail
    internal static let title = L10n.tr("Localizable", "transactionDetail.title", fallback: "Transaction detail")
  }
  internal enum Transactions {
    /// Transactions
    internal static let title = L10n.tr("Localizable", "transactions.title", fallback: "Transactions")
  }
  internal enum ValidationFailed {
    /// Your placed words did not match your secret recovery phrase.
    internal static let description = L10n.tr("Localizable", "validationFailed.description", fallback: "Your placed words did not match your secret recovery phrase.")
    /// Remember, you can't recover your funds if you lose (or incorrectly save) these 24 words.
    internal static let incorrectBackupDescription = L10n.tr("Localizable", "validationFailed.incorrectBackupDescription", fallback: "Remember, you can't recover your funds if you lose (or incorrectly save) these 24 words.")
    /// Ouch, sorry, no.
    internal static let title = L10n.tr("Localizable", "validationFailed.title", fallback: "Ouch, sorry, no.")
    internal enum Button {
      /// Try again
      internal static let tryAgain = L10n.tr("Localizable", "validationFailed.button.tryAgain", fallback: "Try again")
    }
  }
  internal enum ValidationSuccess {
    /// Place that backup somewhere safe and venture forth in security.
    internal static let description = L10n.tr("Localizable", "validationSuccess.description", fallback: "Place that backup somewhere safe and venture forth in security.")
    /// Success!
    internal static let title = L10n.tr("Localizable", "validationSuccess.title", fallback: "Success!")
    internal enum Button {
      /// Take me to my wallet!
      internal static let goToWallet = L10n.tr("Localizable", "validationSuccess.button.goToWallet", fallback: "Take me to my wallet!")
      /// Show me my phrase again
      internal static let phraseAgain = L10n.tr("Localizable", "validationSuccess.button.phraseAgain", fallback: "Show me my phrase again")
    }
  }
  internal enum WelcomeScreen {
    /// Just Loading, one sec
    internal static let subtitle = L10n.tr("Localizable", "welcomeScreen.subtitle", fallback: "Just Loading, one sec")
    /// Powered by Zcash
    internal static let title = L10n.tr("Localizable", "welcomeScreen.title", fallback: "Powered by Zcash")
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
