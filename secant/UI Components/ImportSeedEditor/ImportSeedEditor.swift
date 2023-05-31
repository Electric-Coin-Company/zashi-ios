//
//  ImportSeedEditor.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture
import Generated

struct ImportSeedEditor: View {
    var store: ImportWalletStore
    
    /// Clearance of the black color for the TextEditor under the text (.dark colorScheme)
    init(store: ImportWalletStore) {
        self.store = store
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TextEditor(text: viewStore.bindingForRedactableSeedPhrase(viewStore.importedSeedPhrase))
                .autocapitalization(.none)
                .importSeedEditorModifier()
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
        }
    }
}

struct ImportSeedEditorModifier: ViewModifier {
    var backgroundColor = Color.white
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Text.importSeedEditor.color)
            .padding()
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(Asset.Colors.Mfp.primary.color, lineWidth: 2)
            )
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
