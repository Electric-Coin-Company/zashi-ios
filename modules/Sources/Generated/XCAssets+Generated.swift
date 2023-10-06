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
    public static let splashHi = ImageAsset(name: "SplashHi")
    public static let welcomeScreenLogo = ImageAsset(name: "WelcomeScreenLogo")
    public static let zashiLogo = ImageAsset(name: "ZashiLogo")
  }
  public enum Colors {
    public static let error = ColorAsset(name: "error")
    public static let primary = ColorAsset(name: "primary")
    public static let secondary = ColorAsset(name: "secondary")
    public static let splash = ColorAsset(name: "splash")
    public static let suppressed47 = ColorAsset(name: "suppressed47")
    public static let suppressed72 = ColorAsset(name: "suppressed72")
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
