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
    public enum Partners {
      public static let cbLogo = ImageAsset(name: "cbLogo")
    }
    public static let splashHi = ImageAsset(name: "SplashHi")
    public static let welcomeScreenLogo = ImageAsset(name: "WelcomeScreenLogo")
    public static let zashiLogo = ImageAsset(name: "ZashiLogo")
    public static let alertIcon = ImageAsset(name: "alertIcon")
    public static let arrowLeftLong = ImageAsset(name: "arrowLeftLong")
    public static let buttonCloseX = ImageAsset(name: "buttonCloseX")
    public static let check = ImageAsset(name: "check")
    public static let chevronDown = ImageAsset(name: "chevronDown")
    public static let chevronRight = ImageAsset(name: "chevronRight")
    public static let coinsSwap = ImageAsset(name: "coinsSwap")
    public static let convertIcon = ImageAsset(name: "convertIcon")
    public static let copy = ImageAsset(name: "copy")
    public static let eyeOff = ImageAsset(name: "eyeOff")
    public static let eyeOn = ImageAsset(name: "eyeOn")
    public static let flyReceivedFilled = ImageAsset(name: "flyReceivedFilled")
    public static let gridTile = ImageAsset(name: "gridTile")
    public enum Icons {
      public static let coinbase = ImageAsset(name: "coinbase")
      public static let currencyDollar = ImageAsset(name: "currencyDollar")
      public static let downloadCloud = ImageAsset(name: "downloadCloud")
      public static let key = ImageAsset(name: "key")
      public static let messageSmile = ImageAsset(name: "messageSmile")
      public static let server = ImageAsset(name: "server")
      public static let settings = ImageAsset(name: "settings")
    }
    public static let infoCircle = ImageAsset(name: "infoCircle")
    public static let infoOutline = ImageAsset(name: "infoOutline")
    public static let rateIcons = ImageAsset(name: "rateIcons")
    public static let refreshCCW = ImageAsset(name: "refreshCCW")
    public static let refreshCCW2 = ImageAsset(name: "refreshCCW2")
    public static let restoreInfo = ImageAsset(name: "restoreInfo")
    public static let share = ImageAsset(name: "share")
    public static let shield = ImageAsset(name: "shield")
    public static let shieldTick = ImageAsset(name: "shieldTick")
    public static let shieldedFunds = ImageAsset(name: "shieldedFunds")
    public static let surroundedShield = ImageAsset(name: "surroundedShield")
    public static let tooltip = ImageAsset(name: "tooltip")
    public static let torchOff = ImageAsset(name: "torchOff")
    public static let torchOn = ImageAsset(name: "torchOn")
    public static let upArrow = ImageAsset(name: "upArrow")
    public static let zashiTitle = ImageAsset(name: "zashiTitle")
  }
  public enum Colors {
    public enum ActiveBadge {
      public static let bcg = ColorAsset(name: "bcg")
      public static let outline = ColorAsset(name: "outline")
      public static let text = ColorAsset(name: "text")
    }
    public enum CurrencyConversion {
      public enum Card {
        public static let bcg = ColorAsset(name: "bcg")
        public static let close = ColorAsset(name: "close")
        public static let outline = ColorAsset(name: "outline")
      }
      public static let btnPrimaryBcg = ColorAsset(name: "btnPrimaryBcg")
      public static let btnPrimaryDisabled = ColorAsset(name: "btnPrimaryDisabled")
      public static let btnPrimaryDisabledText = ColorAsset(name: "btnPrimaryDisabledText")
      public static let btnPrimaryText = ColorAsset(name: "btnPrimaryText")
      public static let closeButtonBcg = ColorAsset(name: "closeButtonBcg")
      public static let closeButtonTint = ColorAsset(name: "closeButtonTint")
      public static let optionBcg = ColorAsset(name: "optionBcg")
      public static let optionBtnBcg = ColorAsset(name: "optionBtnBcg")
      public static let optionBtnOutline = ColorAsset(name: "optionBtnOutline")
      public static let optionBtnSet = ColorAsset(name: "optionBtnSet")
      public static let optionBtnSetBcg = ColorAsset(name: "optionBtnSetBcg")
      public static let optionTint = ColorAsset(name: "optionTint")
      public static let outline = ColorAsset(name: "outline")
      public static let primary = ColorAsset(name: "primary")
      public static let tertiary = ColorAsset(name: "tertiary")
    }
    public enum ServerSwitch {
      public static let checkOutline = ColorAsset(name: "checkOutline")
      public static let desc = ColorAsset(name: "desc")
      public static let divider = ColorAsset(name: "divider")
      public static let fieldBcg = ColorAsset(name: "fieldBcg")
      public static let fieldOutline = ColorAsset(name: "fieldOutline")
      public static let highlight = ColorAsset(name: "highlight")
      public static let saveButtonActive = ColorAsset(name: "saveButtonActive")
      public static let saveButtonActiveText = ColorAsset(name: "saveButtonActiveText")
      public static let saveButtonDisabled = ColorAsset(name: "saveButtonDisabled")
      public static let saveButtonDisabledText = ColorAsset(name: "saveButtonDisabledText")
      public static let subtitle = ColorAsset(name: "subtitle")
    }
    public enum Settings {
      public static let coinbaseBcg = ColorAsset(name: "coinbaseBcg")
      public static let coinbaseTint = ColorAsset(name: "coinbaseTint")
    }
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
    public enum V2 {
      public static let bgPrimary = ColorAsset(name: "bgPrimary")
      public static let bgTertiary = ColorAsset(name: "bgTertiary")
      public static let btnDestroyBcg = ColorAsset(name: "btnDestroyBcg")
      public static let btnDestroyBorder = ColorAsset(name: "btnDestroyBorder")
      public static let btnDestroyFg = ColorAsset(name: "btnDestroyFg")
      public static let divider = ColorAsset(name: "divider")
      public static let exchangeRateBcg = ColorAsset(name: "exchangeRateBcg")
      public static let exchangeRateBorder = ColorAsset(name: "exchangeRateBorder")
      public static let strokeSecondary = ColorAsset(name: "strokeSecondary")
      public static let textPrimary = ColorAsset(name: "textPrimary")
      public static let textQuaternary = ColorAsset(name: "textQuaternary")
      public static let textTertiary = ColorAsset(name: "textTertiary")
      public enum Tooltips {
        public static let bcg = ColorAsset(name: "bcg")
        public static let shadow = ColorAsset(name: "shadow")
        public static let textDesc = ColorAsset(name: "textDesc")
        public static let textTitle = ColorAsset(name: "textTitle")
      }
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
