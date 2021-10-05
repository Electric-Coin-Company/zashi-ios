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

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
  }
  internal enum Colors {
    internal static let primaryButton = ColorAsset(name: "PrimaryButton")
    internal static let primaryButtonDisabled = ColorAsset(name: "PrimaryButtonDisabled")
    internal static let primaryButtonPressed = ColorAsset(name: "PrimaryButtonPressed")
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
