//
//  ZashiText.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024.
//

import SwiftUI
import Generated

public struct ZashiText: View {
    private var attributedString: AttributedString
    
    public var body: some View {
        Text(attributedString)
    }
    
    public init(withAttributedString attributedString: AttributedString) {
        self.attributedString = ZashiText.annotateRainbowColors(from: attributedString)
    }

    public init(_ localizedKey: String.LocalizationValue) {
        attributedString = ZashiText.annotateRainbowColors(
            from: AttributedString(localized: localizedKey, including: \.zashiApp))
    }

    private static func annotateRainbowColors(from source: AttributedString) -> AttributedString {
        var attrString = source
        for run in attrString.runs {
            if let zStyle = run.zStyle {
                switch zStyle {
                case .bold:
                    attrString[run.range].font = .system(size: 14, weight: .bold)
                case .italic:
                    attrString[run.range].font = .system(size: 14).italic()
                case .boldItalic:
                    attrString[run.range].font = .system(size: 14, weight: .bold).italic()
                case .link:
                    attrString[run.range].underlineStyle = .single
                }
            }
        }
        return attrString
    }
}

enum ZashiTextAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    enum Value: String, Codable, Hashable {
        case bold
        case italic
        case boldItalic
        case link
    }
    
    static var name: String = "style"
}

public extension AttributeScopes {
    struct ZashiAppAttributes: AttributeScope {
        let zStyle: ZashiTextAttribute
    }
    
    var zashiApp: ZashiAppAttributes.Type { ZashiAppAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.ZashiAppAttributes, T>) -> T {
        self[T.self]
    }
}

struct RainbowText_Previews: PreviewProvider {
    static var previews: some View {
        guard let previewText = try? AttributedString(
            markdown: "Some ^[bold](style: 'bold') ^[italic](style: 'italic') ^[boldItalic](style: 'boldItalic') [link example](https://electriccoin.co) text.",
            including: \.zashiApp) else {
            return ZashiText(withAttributedString: "Couldn't load the preview text.")
        }
        return ZashiText(withAttributedString: previewText)
    }
}
