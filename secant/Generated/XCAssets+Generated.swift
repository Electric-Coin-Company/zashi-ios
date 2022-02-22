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
internal typealias AssetColorTypeAlias = ColorAsset.SystemColor
@available(*, deprecated, renamed: "ImageAsset.UniversalImage", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.UniversalImage

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal enum Backgrounds {
      internal static let callout0 = ImageAsset(name: "callout0")
      internal static let callout1 = ImageAsset(name: "callout1")
      internal static let callout2 = ImageAsset(name: "callout2")
      internal static let callout3 = ImageAsset(name: "callout3")
      internal static let callout4 = ImageAsset(name: "callout4")
    }
    internal enum Icons {
      internal static let list = ImageAsset(name: "list")
      internal static let profile = ImageAsset(name: "profile")
      internal static let shield = ImageAsset(name: "shield")
    }
  }
  internal enum Colors {
    internal enum BackgroundColors {
      internal static let numberedChip = ColorAsset(name: "numberedChip")
      internal static let phraseGridDarkGray = ColorAsset(name: "phraseGridDarkGray")
      internal static let red = ColorAsset(name: "red")
    }
    internal enum Buttons {
      internal static let activeButton = ColorAsset(name: "ActiveButton")
      internal static let activeButtonDisabled = ColorAsset(name: "ActiveButtonDisabled")
      internal static let activeButtonPressed = ColorAsset(name: "ActiveButtonPressed")
      internal static let buttonsTitleShadow = ColorAsset(name: "ButtonsTitleShadow")
      internal static let createButton = ColorAsset(name: "CreateButton")
      internal static let createButtonDisabled = ColorAsset(name: "CreateButtonDisabled")
      internal static let createButtonPressed = ColorAsset(name: "CreateButtonPressed")
      internal static let neumorphicButtonDarkSide = ColorAsset(name: "NeumorphicButtonDarkSide")
      internal static let neumorphicButtonLightSide = ColorAsset(name: "NeumorphicButtonLightSide")
      internal static let neumorphicDarkSide = ColorAsset(name: "NeumorphicDarkSide")
      internal static let neumorphicLightSide = ColorAsset(name: "NeumorphicLightSide")
      internal static let onboardingNavigation = ColorAsset(name: "OnboardingNavigation")
      internal static let onboardingNavigationPressed = ColorAsset(name: "OnboardingNavigationPressed")
      internal static let primaryButton = ColorAsset(name: "PrimaryButton")
      internal static let primaryButtonDisabled = ColorAsset(name: "PrimaryButtonDisabled")
      internal static let primaryButtonPressed = ColorAsset(name: "PrimaryButtonPressed")
      internal static let secondaryButton = ColorAsset(name: "SecondaryButton")
      internal static let secondaryButtonPressed = ColorAsset(name: "SecondaryButtonPressed")
    }
    internal enum Onboarding {
      internal static let badgeShadow = ColorAsset(name: "BadgeShadow")
      internal static let circularFrameDarkOutlineGradientEnd = ColorAsset(name: "CircularFrameDarkOutlineGradientEnd")
      internal static let circularFrameDarkOutlineGradientStart = ColorAsset(name: "CircularFrameDarkOutlineGradientStart")
      internal static let circularFrameGradientEnd = ColorAsset(name: "CircularFrameGradientEnd")
      internal static let circularFrameGradientStart = ColorAsset(name: "CircularFrameGradientStart")
      internal static let navigationButtonDisabled = ColorAsset(name: "NavigationButtonDisabled")
      internal static let navigationButtonEnabled = ColorAsset(name: "NavigationButtonEnabled")
    }
    internal enum ProgressIndicator {
      internal static let gradientLeft = ColorAsset(name: "GradientLeft")
      internal static let gradientRight = ColorAsset(name: "GradientRight")
      internal static let negativeSpace = ColorAsset(name: "NegativeSpace")
    }
    internal enum ScreenBackground {
      internal static let gradientEnd = ColorAsset(name: "gradientEnd")
      internal static let gradientStart = ColorAsset(name: "gradientStart")
      internal static let redGradientEnd = ColorAsset(name: "redGradientEnd")
      internal static let redGradientStart = ColorAsset(name: "redGradientStart")
    }
    internal enum Shadow {
      internal static let emptyChipInnerShadow = ColorAsset(name: "emptyChipInnerShadow")
      internal static let numberedTextShadow = ColorAsset(name: "numberedTextShadow")
    }
    internal enum Text {
      internal static let activeButtonText = ColorAsset(name: "ActiveButtonText")
      internal static let body = ColorAsset(name: "Body")
      internal static let button = ColorAsset(name: "Button")
      internal static let heading = ColorAsset(name: "Heading")
      internal static let medium = ColorAsset(name: "Medium")
      internal static let regular = ColorAsset(name: "Regular")
      internal static let secondaryButtonText = ColorAsset(name: "SecondaryButtonText")
      internal static let titleText = ColorAsset(name: "TitleText")
      internal static let captionText = ColorAsset(name: "captionText")
      internal static let captionTextShadow = ColorAsset(name: "captionTextShadow")
      internal static let highlightedSuperscriptText = ColorAsset(name: "highlightedSuperscriptText")
    }
    internal enum ZcashBadge {
      internal static let zcashLogoFill = ColorAsset(name: "ZcashLogoFill")
      internal static let innerCircle = ColorAsset(name: "innerCircle")
      internal static let outerRingGradientEnd = ColorAsset(name: "outerRingGradientEnd")
      internal static let outerRingGradientStart = ColorAsset(name: "outerRingGradientStart")
      internal static let shadowColor = ColorAsset(name: "shadowColor")
      internal static let thickRing = ColorAsset(name: "thickRing")
      internal static let thinRing = ColorAsset(name: "thinRing")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias SystemColor = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias SystemColor = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var systemColor: SystemColor = {
    guard let color = SystemColor(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  internal private(set) lazy var color: Color = {
    Color(systemColor)
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.SystemColor {
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

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias UniversalImage = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias UniversalImage = UIImage
  #endif

  internal var systemImage: UniversalImage {
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

  internal var image: Image {
    let bundle = BundleToken.bundle
    return Image(name, bundle: bundle)
  }
}

internal extension ImageAsset.UniversalImage {
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
