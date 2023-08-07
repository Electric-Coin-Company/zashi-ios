//
//  ImportSeedEditor.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct ImportSeedEditor: View {
    var store: ImportWalletStore
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            TextEditor(text: viewStore.bindingForRedactableSeedPhrase(viewStore.importedSeedPhrase))
                .autocapitalization(.none)
                .importSeedEditorModifier(Asset.Colors.Mfp.fontDark.color)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
        }
    }
}

struct ImportSeedEditorModifier: ViewModifier {
    var backgroundColor = Color.white
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Mfp.fontDark.color)
            .padding(1)
            .background(backgroundColor)
    }
}

extension View {
    func importSeedEditorModifier(_ backgroundColor: Color = .white) -> some View {
        modifier(ImportSeedEditorModifier(backgroundColor: backgroundColor))
    }
}

struct ImportSeedInputField_Previews: PreviewProvider {
    static let width: CGFloat = 400
    static let height: CGFloat = 200

    static var previews: some View {
        Group {
            ImportSeedEditor(store: .demo)
                .frame(width: width, height: height)
                .applyScreenBackground()
                .preferredColorScheme(.light)
        }
        .previewLayout(.fixed(width: width + 50, height: height + 50))
    }
}
