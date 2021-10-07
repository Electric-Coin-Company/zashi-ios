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
      internal static let lockImage = ImageAsset(name: "LockImage")
    }
    internal enum Icons {
      internal enum IconBadge {
        internal static let iconBadge = ImageAsset(name: "icon_badge")
      }
      internal enum IconList {
        internal static let iconList = ImageAsset(name: "icon_list")
      }
      internal enum IconPerson {
        internal static let iconPerson = ImageAsset(name: "icon_person")
      }
    }
    internal enum Logos {
      internal static let largeYellow = ImageAsset(name: "LargeYellow")
    }
  }
  internal enum Colors {
    internal enum Buttons {
      internal static let primary = ColorAsset(name: "Primary")
      internal static let primaryDisabled = ColorAsset(name: "PrimaryDisabled")
      internal static let primaryPressed = ColorAsset(name: "PrimaryPressed")
    }
    internal enum Onboarding {
      internal static let circularFrame = ColorAsset(name: "CircularFrame")
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
