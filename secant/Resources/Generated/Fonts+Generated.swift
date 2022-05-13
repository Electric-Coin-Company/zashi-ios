// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI
#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias SystemFont = FontConvertible.SystemFont

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum Roboto {
    internal static let black = FontConvertible(name: "Roboto-Black", family: "Roboto", path: "Roboto-Black.ttf")
    internal static let blackItalic = FontConvertible(name: "Roboto-BlackItalic", family: "Roboto", path: "Roboto-BlackItalic.ttf")
    internal static let bold = FontConvertible(name: "Roboto-Bold", family: "Roboto", path: "Roboto-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Roboto-BoldItalic", family: "Roboto", path: "Roboto-BoldItalic.ttf")
    internal static let italic = FontConvertible(name: "Roboto-Italic", family: "Roboto", path: "Roboto-Italic.ttf")
    internal static let light = FontConvertible(name: "Roboto-Light", family: "Roboto", path: "Roboto-Light.ttf")
    internal static let lightItalic = FontConvertible(name: "Roboto-LightItalic", family: "Roboto", path: "Roboto-LightItalic.ttf")
    internal static let medium = FontConvertible(name: "Roboto-Medium", family: "Roboto", path: "Roboto-Medium.ttf")
    internal static let mediumItalic = FontConvertible(name: "Roboto-MediumItalic", family: "Roboto", path: "Roboto-MediumItalic.ttf")
    internal static let regular = FontConvertible(name: "Roboto-Regular", family: "Roboto", path: "Roboto-Regular.ttf")
    internal static let thin = FontConvertible(name: "Roboto-Thin", family: "Roboto", path: "Roboto-Thin.ttf")
    internal static let thinItalic = FontConvertible(name: "Roboto-ThinItalic", family: "Roboto", path: "Roboto-ThinItalic.ttf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, italic, light, lightItalic, medium, mediumItalic, regular, thin, thinItalic]
  }
  internal enum Rubik {
    internal static let light = FontConvertible(name: "Rubik-Light", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let lightItalic = FontConvertible(name: "Rubik-LightItalic", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let blackItalic = FontConvertible(name: "RubikItalic-Black", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let boldItalic = FontConvertible(name: "RubikItalic-Bold", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let extraBoldItalic = FontConvertible(name: "RubikItalic-ExtraBold", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let mediumItalic = FontConvertible(name: "RubikItalic-Medium", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let italic = FontConvertible(name: "RubikItalic-Regular", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let semiBoldItalic = FontConvertible(name: "RubikItalic-SemiBold", family: "Rubik", path: "Rubik-Italic-VariableFont_wght.ttf")
    internal static let black = FontConvertible(name: "RubikRoman-Black", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let bold = FontConvertible(name: "RubikRoman-Bold", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let extraBold = FontConvertible(name: "RubikRoman-ExtraBold", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let medium = FontConvertible(name: "RubikRoman-Medium", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let regular = FontConvertible(name: "RubikRoman-Regular", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let semiBold = FontConvertible(name: "RubikRoman-SemiBold", family: "Rubik", path: "Rubik-VariableFont_wght.ttf")
    internal static let all: [FontConvertible] = [light, lightItalic, blackItalic, boldItalic, extraBoldItalic, mediumItalic, italic, semiBoldItalic, black, bold, extraBold, medium, regular, semiBold]
  }
  internal enum Zboto {
    internal static let regular = FontConvertible(name: "ZbotoRegular", family: "Zboto", path: "Zboto.otf")
    internal static let all: [FontConvertible] = [regular]
  }
  internal static let allCustomFonts: [FontConvertible] = [Roboto.all, Rubik.all, Zboto.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(OSX)
  internal typealias SystemFont = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias SystemFont = UIFont
  #endif

  internal func font(size: CGFloat) -> SystemFont {
    guard let font = SystemFont(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  internal func textStyle(_ textStyle: Font.TextStyle) -> Font {
    Font.mappedFont(name, textStyle: textStyle)
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.SystemFont {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
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

fileprivate extension Font {
  static func mappedFont(_ name: String, textStyle: TextStyle) -> Font {
    let fontSize = UIFont.preferredFont(forTextStyle: self.mapToUIFontTextStyle(textStyle)).pointSize
    return Font.custom(name, size: fontSize, relativeTo: textStyle)
  }

  // swiftlint:disable:next cyclomatic_complexity
  static func mapToUIFontTextStyle(_ textStyle: SwiftUI.Font.TextStyle) -> UIFont.TextStyle {
    switch textStyle {
    case .largeTitle:
      return .largeTitle
    case .title:
      return .title1
    case .title2:
      return .title2
    case .title3:
      return .title3
    case .headline:
      return .headline
    case .subheadline:
      return .subheadline
    case .callout:
      return .callout
    case .body:
      return .body
    case .caption:
      return .caption1
    case .caption2:
      return .caption2
    case .footnote:
      return .footnote
    @unknown default:
      fatalError("Missing a TextStyle mapping")
    }
  }
}

// swiftlint:enable convenience_type
