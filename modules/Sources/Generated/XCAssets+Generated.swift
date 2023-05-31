// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI
#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.SystemColor", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.SystemColor
@available(*, deprecated, renamed: "ImageAsset.UniversalImage", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.UniversalImage

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Assets {
    public enum Backgrounds {
      public static let callout0 = ImageAsset(name: "callout0")
      public static let callout1 = ImageAsset(name: "callout1")
      public static let callout2 = ImageAsset(name: "callout2")
      public static let callout3 = ImageAsset(name: "callout3")
      public static let callout4 = ImageAsset(name: "callout4")
      public static let calloutBackupFailed = ImageAsset(name: "calloutBackupFailed")
      public static let calloutBackupFlow1 = ImageAsset(name: "calloutBackupFlow1")
      public static let calloutBackupSucceeded = ImageAsset(name: "calloutBackupSucceeded")
    }
    public enum Icons {
      public static let qrCode = ImageAsset(name: "qrCode")
    }
    public static let welcomeScreenLogo = ImageAsset(name: "WelcomeScreenLogo")
  }
  public enum Colors {
    public enum BackgroundColors {
      public static let numberedChip = ColorAsset(name: "numberedChip")
      public static let phraseGridDarkGray = ColorAsset(name: "phraseGridDarkGray")
      public static let red = ColorAsset(name: "red")
      public static let staticWelcomeScreen = ColorAsset(name: "staticWelcomeScreen")
    }
    public enum Buttons {
      public static let activeButton = ColorAsset(name: "ActiveButton")
      public static let activeButtonDisabled = ColorAsset(name: "ActiveButtonDisabled")
      public static let activeButtonPressed = ColorAsset(name: "ActiveButtonPressed")
      public static let buttonsTitleShadow = ColorAsset(name: "ButtonsTitleShadow")
      public static let neumorphicButtonDarkSide = ColorAsset(name: "NeumorphicButtonDarkSide")
      public static let neumorphicButtonLightSide = ColorAsset(name: "NeumorphicButtonLightSide")
      public static let onboardingNavigation = ColorAsset(name: "OnboardingNavigation")
      public static let onboardingNavigationPressed = ColorAsset(name: "OnboardingNavigationPressed")
      public static let primaryButton = ColorAsset(name: "PrimaryButton")
      public static let primaryButtonDisabled = ColorAsset(name: "PrimaryButtonDisabled")
      public static let primaryButtonPressed = ColorAsset(name: "PrimaryButtonPressed")
      public static let secondaryButton = ColorAsset(name: "SecondaryButton")
      public static let secondaryButtonPressed = ColorAsset(name: "SecondaryButtonPressed")
    }
    public enum CheckCircle {
      public static let externalRing = ColorAsset(name: "externalRing")
      public static let internalRing = ColorAsset(name: "internalRing")
    }
    public enum Cursor {
      public static let bar = ColorAsset(name: "Bar")
    }
    public enum Mfp {
      public static let background = ColorAsset(name: "background")
      public static let fontDark = ColorAsset(name: "fontDark")
      public static let fontLight = ColorAsset(name: "fontLight")
      public static let primary = ColorAsset(name: "primary")
    }
    public enum Onboarding {
      public static let badgeShadow = ColorAsset(name: "BadgeShadow")
      public static let circularFrameDarkOutlineGradientEnd = ColorAsset(name: "CircularFrameDarkOutlineGradientEnd")
      public static let circularFrameDarkOutlineGradientStart = ColorAsset(name: "CircularFrameDarkOutlineGradientStart")
      public static let circularFrameGradientEnd = ColorAsset(name: "CircularFrameGradientEnd")
      public static let circularFrameGradientStart = ColorAsset(name: "CircularFrameGradientStart")
      public static let navigationButtonDisabled = ColorAsset(name: "NavigationButtonDisabled")
      public static let navigationButtonEnabled = ColorAsset(name: "NavigationButtonEnabled")
      public static let neumorphicDarkSide = ColorAsset(name: "NeumorphicDarkSide")
      public static let neumorphicLightSide = ColorAsset(name: "NeumorphicLightSide")
      public static let badgeBackground = ColorAsset(name: "badgeBackground")
    }
    public enum ProgressIndicator {
      public static let gradientLeft = ColorAsset(name: "GradientLeft")
      public static let gradientRight = ColorAsset(name: "GradientRight")
      public static let negativeSpace = ColorAsset(name: "NegativeSpace")
      public static let holdToSendButton = ColorAsset(name: "holdToSendButton")
    }
    public enum QRScan {
      public static let frame = ColorAsset(name: "frame")
    }
    public enum ScreenBackground {
      public static let amberGradientEnd = ColorAsset(name: "amberGradientEnd")
      public static let amberGradientMiddle = ColorAsset(name: "amberGradientMiddle")
      public static let amberGradientStart = ColorAsset(name: "amberGradientStart")
      public static let gradientDarkEnd = ColorAsset(name: "gradientDarkEnd")
      public static let gradientDarkStart = ColorAsset(name: "gradientDarkStart")
      public static let gradientEnd = ColorAsset(name: "gradientEnd")
      public static let gradientStart = ColorAsset(name: "gradientStart")
      public static let greenGradientEnd = ColorAsset(name: "greenGradientEnd")
      public static let greenGradientStart = ColorAsset(name: "greenGradientStart")
      public static let modalDialog = ColorAsset(name: "modalDialog")
      public static let redGradientEnd = ColorAsset(name: "redGradientEnd")
      public static let redGradientStart = ColorAsset(name: "redGradientStart")
      public static let semiTransparentGradientEnd = ColorAsset(name: "semiTransparentGradientEnd")
      public static let semiTransparentGradientStart = ColorAsset(name: "semiTransparentGradientStart")
    }
    public enum Shadow {
      public static let drawerShadow = ColorAsset(name: "drawerShadow")
      public static let emptyChipInnerShadow = ColorAsset(name: "emptyChipInnerShadow")
      public static let holdToSendButtonShadow = ColorAsset(name: "holdToSendButtonShadow")
      public static let numberedTextShadow = ColorAsset(name: "numberedTextShadow")
    }
    public enum Text {
      public static let activeButtonText = ColorAsset(name: "ActiveButtonText")
      public static let body = ColorAsset(name: "Body")
      public static let button = ColorAsset(name: "Button")
      public static let drawerTabsText = ColorAsset(name: "DrawerTabsText")
      public static let heading = ColorAsset(name: "Heading")
      public static let importSeedEditor = ColorAsset(name: "ImportSeedEditor")
      public static let invalidEntry = ColorAsset(name: "InvalidEntry")
      public static let medium = ColorAsset(name: "Medium")
      public static let regular = ColorAsset(name: "Regular")
      public static let secondaryButtonText = ColorAsset(name: "SecondaryButtonText")
      public static let titleText = ColorAsset(name: "TitleText")
      public static let transactionDetailText = ColorAsset(name: "TransactionDetailText")
      public static let transactionRowSubtitle = ColorAsset(name: "TransactionRowSubtitle")
      public static let validMnemonic = ColorAsset(name: "ValidMnemonic")
      public static let balanceText = ColorAsset(name: "balanceText")
      public static let captionText = ColorAsset(name: "captionText")
      public static let captionTextShadow = ColorAsset(name: "captionTextShadow")
      public static let forDarkBackground = ColorAsset(name: "forDarkBackground")
      public static let highlightedSuperscriptText = ColorAsset(name: "highlightedSuperscriptText")
      public static let moreInfoText = ColorAsset(name: "moreInfoText")
    }
    public enum TextField {
      public static let multilineOutline = ColorAsset(name: "MultilineOutline")
      public static let titleAccessoryButton = ColorAsset(name: "TitleAccessoryButton")
      public static let titleAccessoryButtonPressed = ColorAsset(name: "TitleAccessoryButtonPressed")
      public enum Underline {
        public static let gray = ColorAsset(name: "Gray")
        public static let purple = ColorAsset(name: "Purple")
      }
    }
    public enum TransactionDetail {
      public static let failedMark = ColorAsset(name: "FailedMark")
      public static let highlightMark = ColorAsset(name: "HighlightMark")
      public static let inactiveMark = ColorAsset(name: "InactiveMark")
      public static let neutralMark = ColorAsset(name: "NeutralMark")
      public static let succeededMark = ColorAsset(name: "SucceededMark")
    }
    public enum ZcashBadge {
      public static let zcashLogoFill = ColorAsset(name: "ZcashLogoFill")
      public static let innerCircle = ColorAsset(name: "innerCircle")
      public static let outerRingGradientEnd = ColorAsset(name: "outerRingGradientEnd")
      public static let outerRingGradientStart = ColorAsset(name: "outerRingGradientStart")
      public static let shadowColor = ColorAsset(name: "shadowColor")
      public static let thickRing = ColorAsset(name: "thickRing")
      public static let thinRing = ColorAsset(name: "thinRing")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias SystemColor = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias SystemColor = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var systemColor: SystemColor = {
    guard let color = SystemColor(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  public private(set) lazy var color: Color = {
    Color(systemColor)
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.SystemColor {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias UniversalImage = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias UniversalImage = UIImage
  #endif

  public var systemImage: UniversalImage {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = UniversalImage(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = UniversalImage(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  public var image: Image {
    let bundle = BundleToken.bundle
    return Image(name, bundle: bundle)
  }
}

public extension ImageAsset.UniversalImage {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
