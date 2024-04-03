# Changelog
All notable changes to this application will be documented in this file.

Please be aware that this changelog primarily focuses on user-related modifications, emphasizing changes that can 
directly impact users rather than highlighting other crucial architectural updates. 

## [Unreleased]

### Added
- Open settings button added to the scan screen for a case when the camera is disabled.

## 1.0.4 build 2 (2024-03-29)

### Added
- Tap to Copy memo.

### Fixed
- Tap to Copy transaction ID button animation.
- Transparent balance added up to the total balance.
- Tap to transparent funds hint box area.

## 1.0.4 build 1 (2024-03-28)

### Fixed
- Orchard subtree roots are now fetched alongside Sapling subtree roots.

## 1.0.3 build 1 (2024-03-27)

### Fixed
- Bug in note selection when sending to a transparent recipient.

## 1.0.2 build 1 (2024-03-27)

### Fixed
- Bug in an SQL query that prevented shielding of transparent funds.

## 1.0.1 build 3 (2024-03-26)

### Added
- Proposal API integrated with error handling for multi-transaction Proposals.
- Privacy info manifest.
- Orchard support.
- Seed validation for case when Zashi is migrated to another device.

### Fixed
- White area above the keyboard has been removed.

## 1.0 build 3 (2024-03-13)

### Changed
- Settings screen options have been reduced and some were moved to the new Advanced Settings screen.
- Scan of QR codes has been re-worked with new design and behaviours.
- Security warning consent extended with crash reports.
- Available balance component shows a spinner instead of zero value when processing spendable balance.

### Added
- Pending values (changes) at the Balances tab.
- Choose a Server feature: available at settings, pre-defined servers + custom server setup.
- Account tab UI tweaks for no transactions available. 

### Fixed
- Restore mode in the UI was missing when Zashi was deleted from an iPhone and reinstalled again.
- Syncing bar in the restore mode bottom padding.
- Missing exit button at backup phrase screen when no words are stored in the keychain.
- Failed transactions are no longer at the top of the transaction history but mixed with the transactions around the time it failed.
- Synchronization progress bar starts at the expected percentage as oposed to previous behaviour when it started with 0% and jumped to the expected one in a few seconds.
- iPhone SE recovery phrase screen is not trailing words anymore.
- Security audit issues has been resolved.

### Removed
- Pull to refresh the transaction history.

## 0.2.0 build 15 (2024-01-31)

### Fixed
- Shileding of transparent funds.

## 0.2.0 build 14 (2024-01-30)

### Updated
- SDK 2.0.7 adopted with the performance optimizations on the rust side.

## 0.2.0 build 13 (2024-01-28)

### Added
- Share QR code of addresses via system share dialog.

### Fixed
- `Keys Missing` error dialog was sometimes triggered as a false positive due to system overload and keychain API unresponsivity in expected time. Retry logic was implemented to pass this state. Also the app always lands users to the Account tab instead of lock them on a splash screen with no options to solve this state.

## 0.2.0 build 12 (2024-01-20)

### Added
- The exported logs also show the shielded balances (total & verified) for every finished sync metric.
- Synchronization in the background. When the iPhone is connected to the power and wifi, the background task will try to synchronize randomly between 3-4am.
- Restore of the wallet is now indiated in the UI throughout the application.
- A hint box that elucidates transparent funds and shielding on the Balances tab.

### Fixed
- The export buttons are disabled when exporting of the private data is in progress.
- The alert message and title for the failed transaction send.  

## 0.2.0 build 11 (2023-12-13)

### Added
- Option to export SDK and wallet logs in `Export private data` screen.

### Changed
- The background of Onboarding and some of the Settings screen has been updated to show a subtle texture of a grid pattern.
- The sapling address + QR code has been restored on the Receive tab (for testnet only.)

### Fixed
- Fixed a bug that caused spends to appear to be stuck.
- The confirmation screen has been altered such that the message bubble is rendered only when the message is non-empty. 

## 0.2.0 build 10 (2023-11-30)

### Changed
- The way how the balances (zatoshi amounts/values) are represented has been updated accoridng to the latest requirements. In general any zatoshi value has 2 major states, expanded or abbreviated. Trailing zeroes are trimmed when expanded.
- The `Balances` screen has been redesigned: new progress bar with the status of the synchronization, all balances available. Penging fields are disabled for now and show only zeroes until support from the SDK is implemented.
- When the send button is tapped, the sending title + spinner is shown instead of just the spinner. Also, when the send is done, and redirect to the Account page is done, the sending transaction is already populated in the list. The lag between it was presented has been fixed.

### Removed
- [testnet only] The sapling address and the QR of it has been removed from the receive screen. The only meaningful options are the UA and the transparent addresses. 

### Added
- Confirmation screen when sending funds. The initial screen is about filling in the address, amount and message (optional). The butoon `review` leads to a brand new screen where the summary of the transaction is presented. The send is confirmed by tapping the send button. Going back to update send data is possible via `go back` button.

## 0.2.0 build 9 (2023-11-14)

### Changed
- Send (tab) redesigned: All the input fields are at the same screen. The screen is scrollable so it's usable on every possible iPhone.  
- Complete redesign of transactions on the Account tab. Expandable transactions show details of it, including options to copy transaction IDs as well as addresses. 

### Added
- The concept of read/unread transactions with the message (memo) implemented. The color of the icon of received transaction that holds message and hasn't been read yet is yellow. Once the transaction is expanded, the icon's color flips to the black and the state is persisted.

## 0.2.0 build 6 (2023-11-01)

### Added
- Option to export private data: brand new screen accessible via Settings, where once consent acknowledged, a user can export a database of data. Important note: the data are sensitive because it holds some information about user's transactions and history but spending keys are not exported so lost of funds is not possible. 

## 0.2.0 build 5 (2023-10-26)

### Changed
- Settings screen has been redesigned and options on the screen changed. 
- Truncation of the balances changed from 8 floating points to the 3 only.
- Restore from the seed flow and UI updated.

### Added
- Option to copy the seed to the pasteboard when a new wallet is created and the seed presented.  

## 0.2.0 build 4 (2023-10-13)

### Changed
- About screen UI updated.
- The main navigation of the Zashi changed, now the wallet is tab based with Account, Send, Receive and Balances tabs.
- Home screen is now called Account.
- Receive screen UI updated.
- Recovery screen UI updated (the screen with the seed presented).

### Added
- The security warning screen with that is presented when the new wallet is created now holds a link in the text that takes a user to the privacy policy.   

## 0.2.0 build 3 (2023-10-05)

### Changed
- Zashi design buttons
- Splash screen: new animated screen with the logo + HI text.
- Security warning screen UI updated.
- State and progress of the synchronizer moved from the Home screen to the balance breakdown screen.

## 0.2.0 build 1 (2023-10-03)

### Changed
- The send button is disabled until the spendable balance is not a zero.

### Added
- The wallet now handles lifecycle events: when the app goes to the background and back to the foreground. That fixed lightwalletd errors.  

# Previous Changelog records before we rethink the idea of the changelog and before Zashi design 

## 0.0.1 build 52
- [#709] Better error handling in tests (#713)

## 0.0.1 build 51
- [#711] Transaction History not shown (#715) 

## 0.0.1 build 50
- [#707] Adopt latest SDK (#708)
- [#705] Transaction detail lacks memo and addresses (#706)
- [#265] Integrate App Rating Alert (#703)
- [#698] RootView to use SwitchStore (#699)
- [#691] Adopt sync/async synchronizer changes (#696)
- [#683] Zip log files into one (#692)
- [#684] Improvements for the derivation tool dependency (#689)
- [#678] Adopt TCA 0.52.0 (#688)
- [#682] Adopt removal of the Notification center on the SDK side (#687)

## 0.0.1 build 49
- [#673] End to end bugfix (#679)
Bugs fixed:
 - derivation tool live key has hardcoded mainnet so it doesn't recognise and validate zcash testnet addresses
 - send to transparent address fails because of Memo("") provided instead of nil
 - when transparent address is filled in a send form, the memo input is still present in the UI, memo is not supported by transparent addresses so it should be removed

## 0.0.1 build 48
- [#676] fix About.swift not being present on mainnet target (#677)
- [#654] Convert SDKSynchronizerDependency to regular TCA dependency (#672)
# 0.0.1 build 47
- [#653] Adopt SDK initialisation changes (#671)
- [#668] Balance Breakdown design enhancements (#669)
- [#660] Fix missing percentage on homepage while syncing (#670)
- [#663] Shield Funds button is enabled when there are no funds to shield (#665)
- [#666] Remove Graphics from "create new wallet" screen (#667)
- [#661] Send Button works even if it's apparently disabled (#664)
- [#660] Settings button is not part of a navigation bar (#662)
- [#658] About Screen with version (#659)
- [#652] Each logged TCA actions appears twice in the log (#657)

## 0.0.1 build 46
- [#626] Small UI-UX fixes for 0.0.1-45 (#649)
- [#650] Layout changes for the send screen (#651)
- [#647] Adopt 0.19.1-beta (#648)
- [#597] Sync cannot be retried after a failure (#646)
- [#631] Make Send Form fields avoid being blocked by keyboard (#645)
- [#599] Add ability to shield funds (#641)
- [#632] Show error message for failed transaction (#642)
- [#628] TAZ vs ZEC builds (#637)
- [#639] Show valid balance after app start (#640)
- [#618] Require specific version of SwiftGen (#638)
# 0.0.1 build 45
- [#635] Fix HomeTests
- [#633] build and release from tag 0.0.1-45
- [#611] Disable Send ZEC button when sync in progress 
- [#617] Use L10n for all the texts in the app (#627)
- [#594] Don't Allow user to proceed to send funds if they are not available for spend (#629)
- [#595] Visbility of fiat conversion on homeage depends on feature flag (#625)
- [#592] Add export logs to debug menu (#621)
- PR Fix how sync progress is displayed (#624)
- [#618] Use SwiftGen to generate L10n structure (#619)
- [#609] Split birthday from the import seed phrase (#622)
# 0.0.1 build 44
This is the baseline build for iOS Re-Scoping epic. 
- [#819] build and release from tag 0.0.1-44
- [#566] Change colors app-wide (#603)
- [#613] Adopt ZcashLightClientKit version 0.19.0-beta (#616)
- [#614] Fix error handling when calling wipe (#615)
- [#605] Change "Your UA" for "Your Address" (#606)
- [#553] Add Mainnet and Testnet icons (#612)
- Test mainnet release (#593)
- [#557] Nav Changes (#602)
- [#576] All the errors are handled by alert (#589)

# 0.0.1 build 43
- [#529] Replace OSLogger_ with OSLogger from the SDK (#590)
- [#556] Hide post-seed backup flow and rework screenshot tests (#591)
- [#575] Add support for sending feedback (#588)
- [#546] Update how swiftlint is used (#547)
- [#586] secantTests.AppInitializationTests Tests fail on CI (#587)
- [#535] Use 0.18.0's wipe() instead of obsolete nuke approach (#549)
- [#554] Add ability to update feature flags from debug screen (#583)
- [#554] Use WalletConfigProvider and WalletConfig in the TCA (#582)
- [#565] Add transaction details as standalone screen (#581)
- [#562] Clean up the Send screen (#580)
- [#577] Fix TCA warning (#578)
- [#806] Mainnet target is using testnet endpoint (#579)
# 0.0.1 build 42
- CI changes that fixed release of mainnet and testnet apps to testflight
# 0.0.1 build 41
[#554] Add WalletConfigProvider (#574)
[#560] Remove QR code scanning from the home screen (#571)
[#207] create Secant Mainnet target (#550)
[#564] Add transaction history as standalone screen (#569)
[#537] Flaky navigation issue (#567)
[#545] Fix CI issues with PR builds (#548)
[#544] Fix swiftlint warnings (#544)
# 0.0.1 build 40 
- [#541] Adopt Latest main commit of SDK (#542)
# 0.0.1 build 39
- [#238] Add crash reporter to secant (#531)
- [#444] Ensure that sensitive information can't be logged intentionally or by accident (#536)
- [#538] Update and adapt 0.50.2 TCA (#539)
- [#516] Adopt unreleased changes that will go live with SDK 0.18.0-beta release (#532)
- [#126] TCA component for user logs (#526)
- [#521] Update format for the Swiftlint TODO rule (#523)
- [#517] QR codes integration into the wallet details and send feature (#518)
- [#514] Adopt Unified Addresses (#515)
# 0.0.1 build 37

- [#512] Check that every TODO in code has an open issue (#513)
- [#507] Community PR - Fix typos (#507)
- [#505] AppTests refactor to RootTests (#506)
- [#179] Broken Onboarding UI for .accessibilityLarge (#504)
- [#494] Simplification of the AppReducer's body property (#501)
- [#495] Rename AppStore to avoid conceptual confusions (#503)
- [#184] ProgressView is no longer .easeInOut animated (#502)
- [#499] Refactor Route to Destination (#500)
- [#442] Adopt SDK 0.17.0 (#496)
- [#492] Update TCA to 0.46.0 (#493)
- [#490] Consolidation of TCA dependencies - 2nd batch (#491)
- [#477] Consolidation of TCA dependencies (#489)
- [#469] Migrate AppStore to ReducerProtocol (#488)
- [#470] Migrate Home to ReducerProtocol (#487)
- [#463] Migrate SendFlow to ReducerProtocol (#486)
- [#461] Migrate OnboardingFlow to ReducerProtocol (#485)
- [#462] Migrate Profile to ReducerProtocol (#484)
- [#467] Migrate TransactionAmountTextField to ReducerProtocol (#483)
- [#471] Migrate CheckCircle to ReducerProtocol (#479)
- [#464] Migrate MultilineTextField to ReducerProtocol (#476)
- [#481] Update TCA to 0.45.0 (#482)
- [#472] Migrate Request, WalletInfo and Sandbox to ReducerProtocol (#480)
- [#468] Migrate CurrencySelection to ReducerProtocol (#478)
- [#466] Migrate TransactionAddressTextField to ReducerProtocol (#475)
- [#460] Migrate AddressDetails to ReducerProtocol (#473)
- [#465] Migrate TCATextField to ReducerProtocol (#474)
- [#452] Migrate Settings to ReducerProtocol (#459)
- [#451] Migrate Welcome to ReducerProtocol (#458)
- [#450] Migrate WalletEvents to ReducerProtocol (#457)
- [#449] Migrate Scan to ReducerProtocol (#456)
- [#447] Migrate BalanceBreakdown to ReducerProtocol (#453)
- [#448] Migrate ImportWallet to ReducerProtocol (#454)
- [#445] Migrate RecoveryPhraseValidationFlowStore to ReducerProtocol (#446)
- [#441] Migrate RecoveryPhraseDisplayStore to ReducerProtocol (#443)
- [#439] Update illustrations (#440)
- [#436] Adopt new update of TCA (#438)
- [#432] Navigation is broken for 2nd+ sending flow (#433)
- [#434] Fix circural image (#435)
- [#428] Update onboarding screens (#431)
- [#82] Add Sending in progress screen (#430)
- [#427] Add not enough disk space screen (#429)
- [#81] Update Send Confirmation screen (#426)
- [#50] Disable third party keyboards (#424)
- [#25] Add swiftlint rule to detect TODO without issue number (#425)
- [#379] Show alert before follow a Block explorer link (#423)
- [#420] Get rid of warnings about UserDefaults not being Sendable (#422)
- [#415] Update TCA library to version 0.40.2 (#419)
- [#417] Target secant-testnet now uses testnet instead of mainnet (#418)

## 0.0.1 build 35
- [#409] Rewrite LocalAuthenticationHandler so it supports new concurrency (#410)
- [#224] [Scaffold] Balance Breakdown (#412)
- [#408] Reduce dependency on TCA in the dependencies (#413)
- [#404] Update to ComposableArchitecture 0.39.0 (#406)
- [#146] [UI Component] multiple line textfield (#400)
## 0.0.1 build 34
- [#75] [Scaffold] Settings Screen (#398)
- [#394] adopt ZcashLightClientKit 0.16.x-beta (#397)
## 0.0.1 build 33
- [#102] [Functional] Full Wallet History
- [#153] [Scaffold] Progress Status Circular Bar (#389)
## 0.0.1 build 32
- [#73] [Scaffold] Profile Screen (#386)
- [#384] Update to ComposableArchitecture 0.38.2 (#385)
## 0.0.1 build 31
- [#362] [scaffold] Pending Transaction Details (#381)
- [#96] [Scaffold] Received Transaction Details (#378)
- [#98] [Scaffold] Full Wallet History (#376)
- [#375] Update ComposableArchitecure to 0.37.0 (#377)
- [#327] Navigation/Routing for the deeplinks (#371)

## 0.0.1 build 29
- [#358] Xcode project broken (#360)
- [#324] WrappedFeedbackGenerator refactor (#357)
- [#346] Take Synced home screen snapshot (#356)
- [#342] Take empty validation puzzle snapshot (#355)
- [#341] Take Phrase Display Snapshots (#354)
- [#345] Take wallet import snapshot (#353)
- [#340] Take Onboarding Snapshots (#352)
- [#337] Set up Snapshot Testing (#350)
- [#318] Build 0.0.1-27 + changelog (#349)
## 0.0.1 build 27
- [#222] Tests for the initialisation check and process (#334)
- [#312] WrappedNumberFormatter (#336)
- [#323] Unit/Integration tests for Home (#335)
- [#329] Update wallet to use Zatoshi type (#333)
- [#272] Decimals and Zatoshi type (#330)
## 0.0.1 build 25
- [#180] Project Structure & TCA Code Consistency Document (#314)
This is a huge refactor in the project structure. Please see related
issue for more details.
- [#300] Use .live pasteboard on live views of the app. (#320)
- [#319] Update TCA to 0.35.0 (#326)
- [#285] Advanced Routing: setting a route may vary depending on the originating context (#325)
- [#106] [Scaffold] Scan QR Screen (#321)
- [#301] Import Wallet does not have a Birthday input field (#328)
- [#331] Update Secant ZcashLightClientKit 0.14.0-beta

## 0.0.1 build 24
- [#294] Send Screen - amount + address fields (#308)
## 0.0.1 build 23
- [#287] updated changelog with issues that fixed the broken build (#309)
- [#306] [#215] Swiftlint and other warnings + build errors (#307)
- [#287] CHANGELOG and build number bump for 0.0.1-23 (#305)
- [#302] Synchronizer status on Home Screen (#304)
- [#212] Wrapped user defaults (#298)
- [#80] Scaffold - Send functionality (#297)
- [#295] Update "Commit Messages" section of CONTRIBUTING.md (#296)
- [#293] first draft of history of transactions (#293)
- [#284]: (Non)scrollable Transactions list based on Drawer

## 0.0.1 build 21
- [#258]: User can take the backup test successfully more than once (#282)\
- [#279]: update swiftlint (#280)
- [#283]: drawer animation fixed (#283)
- [#284]: Static welcome screen (#274)
- [#276]: [Scaffold] Drawer for the Home Screen (#275)
- [#239]: [Functional] Integration of the ZcashSDK
- [#266]: Placeholder home screen/refactor previous home to debug screen
- [#256]: [Recovery Phrase Display] Dark mode word chips' color does not match the designs
- [#268]: [Critical] App get stuck after start #268
- [#260]: Wrapped Derivation Tool 
- [#254]: Testable and more readable structure for the AppReducer
- [#231]: Wallet Storage unit tests vs. integration tests
- [#253]: [Functional] Import wallet
- [#250]: Recovery Phrase Validation, words to complete puzzle are not shuffled
## 0.0.1 build 19
- [#242]: NukeWallet in the debug menus for testing purposes

## 0.0.1 build 18
- [#200]: Move Debug Menus to a hidden screen
- [#197]: Ability to know whether wallet has been initialized
- [#202]: Connect onboarding flow to Recovery Phrase backup on Create New wallet

## 0.0.1 build 17
- [#196]: User Preferences Storage
- [#157]: Keystoring protocol
- [#155]: Add MnemonicSwift to the project

## 0.0.1 build 16
- [#205]: Validation Failure/Success updated to handle dark mode
- [#191]: Badges updated to use symbols
- [#181]: Badge animation fix
- [#140]: Validation Failed Screen Design updates
- [#139]: Validation Success Screen Design updates
- [#183]: remove Create new button style
- [#147]: Recovery Phrase Validation PreambleScreen
- [#165]: [Scaffold] wallet import screen
- [#174]: Wallet localization preparation
## 0.0.1 Build 15
- Issue #163: Recovery Phrase validation feedback
- Issue #138: Enhancements to Onboarding Flows
- Issue #158: M1 macs have problems with Swiftlint
- PR #164: Typos Fix in Documentation and code
- Issue #159: Enhancement of the index clamping property wrapper
- Issue #44: Recovery Phrase Validation flow  + tests

--------
- Added SwiftGen templates for generating asset helper files.
- Added Code Review Guides, Changelog, pull request and issue templates, SwiftLint Rules

