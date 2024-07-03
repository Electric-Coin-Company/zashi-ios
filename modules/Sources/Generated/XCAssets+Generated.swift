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
    public static let fly = ImageAsset(name: "Fly")
    public static let flyReceived = ImageAsset(name: "FlyReceived")
    public static let splashHi = ImageAsset(name: "SplashHi")
    public static let welcomeScreenLogo = ImageAsset(name: "WelcomeScreenLogo")
    public static let zashiLogo = ImageAsset(name: "ZashiLogo")
    public static let alertIcon = ImageAsset(name: "alertIcon")
    public static let copy = ImageAsset(name: "copy")
    public static let deeplinkWarning = ImageAsset(name: "deeplinkWarning")
    public static let eyeOff = ImageAsset(name: "eyeOff")
    public static let eyeOn = ImageAsset(name: "eyeOn")
    public static let flyReceivedFilled = ImageAsset(name: "flyReceivedFilled")
    public static let gridTile = ImageAsset(name: "gridTile")
    public static let restoreInfo = ImageAsset(name: "restoreInfo")
    public static let share = ImageAsset(name: "share")
    public static let shield = ImageAsset(name: "shield")
    public static let surroundedShield = ImageAsset(name: "surroundedShield")
    public static let torchOff = ImageAsset(name: "torchOff")
    public static let torchOn = ImageAsset(name: "torchOn")
    public static let upArrow = ImageAsset(name: "upArrow")
    public static let zashiLogoBolder = ImageAsset(name: "zashiLogoBolder")
    public static let zashiTitle = ImageAsset(name: "zashiTitle")
  }
  public enum Colors {
    public static let background = ColorAsset(name: "background")
    public static let btnDarkShade = ColorAsset(name: "btnDarkShade")
    public static let btnLabelShade = ColorAsset(name: "btnLabelShade")
    public static let btnLightShade = ColorAsset(name: "btnLightShade")
    public static let btnPrimary = ColorAsset(name: "btnPrimary")
    public static let btnSecondary = ColorAsset(name: "btnSecondary")
    public static let error = ColorAsset(name: "error")
    public static let messageBcgBorder = ColorAsset(name: "messageBcgBorder")
    public static let messageBcgDisabled = ColorAsset(name: "messageBcgDisabled")
    public static let messageBcgReceived = ColorAsset(name: "messageBcgReceived")
    public static let pickerBcg = ColorAsset(name: "pickerBcg")
    public static let pickerSelection = ColorAsset(name: "pickerSelection")
    public static let pickerTitleSelected = ColorAsset(name: "pickerTitleSelected")
    public static let pickerTitleUnselected = ColorAsset(name: "pickerTitleUnselected")
    public static let primary = ColorAsset(name: "primary")
    public static let primaryTint = ColorAsset(name: "primaryTint")
    public static let restoreUI = ColorAsset(name: "restoreUI")
    public static let secondary = ColorAsset(name: "secondary")
    public static let shade30 = ColorAsset(name: "shade30")
    public static let shade47 = ColorAsset(name: "shade47")
    public static let shade55 = ColorAsset(name: "shade55")
    public static let shade72 = ColorAsset(name: "shade72")
    public static let shade85 = ColorAsset(name: "shade85")
    public static let shade92 = ColorAsset(name: "shade92")
    public static let shade97 = ColorAsset(name: "shade97")
    public static let splash = ColorAsset(name: "splash")
    public static let syncProgresBcg = ColorAsset(name: "syncProgresBcg")
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
