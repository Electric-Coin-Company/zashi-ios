//
//  ImportSeedEditor.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import SwiftUI
import ComposableArchitecture

struct ImportSeedEditor: View {
    var store: ImportWalletStore
    
    /// Clearance of the black color for the TextEditor under the text (.dark colorScheme)
    init(store: ImportWalletStore) {
        self.store = store
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TextEditor(text: viewStore.binding(\.$importedSeedPhrase))
                .importSeedEditorModifier()
                .padding(28)
        }
    }
}

struct ImportSeedEditorModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Text.importSeedEditor.color)
            .padding()
            .background(Color.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black, lineWidth: 2)
            )
    }
}

extension View {
    func importSeedEditorModifier() -> some View {
        modifier(ImportSeedEditorModifier())
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
            
            ImportSeedEditor(store: .demo)
                .frame(width: width, height: height)
                .applyScreenBackground()
                .preferredColorScheme(.dark)
        }
        .previewLayout(.fixed(width: width + 50, height: height + 50))
    }
}
