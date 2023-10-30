//
//  ImportBirthdayView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/06/2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ImportBirthdayView: View {
    var store: ImportWalletStore

    public init(store: ImportWalletStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center) {
                ZashiIcon()
                    .padding(.vertical, 30)

                Text(L10n.ImportWallet.Birthday.title)
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .foregroundColor(Asset.Colors.primary.color)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)

                Text(L10n.ImportWallet.optionalBirthday)

                TextField("", text: viewStore.bindingForRedactableBirthday(viewStore.birthdayHeight))
                    .frame(height: 40)
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .overlay {
                        Color.black
                            .frame(height: 1)
                            .offset(x: 0, y: 20)
                    }
                
                Spacer()

                Button(L10n.ImportWallet.Button.restoreWallet.uppercased()) {
                    viewStore.send(.restoreWallet)
                }
                .zcashStyle()
                .disabled(!viewStore.isValidForm)
                .frame(width: 236)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 70)
            .applyScreenBackground()
            .scrollableWhenScaledUp()
            .onAppear(perform: { viewStore.send(.onAppear) })
            .zashiBack()
        }
    }
}

// MARK: - Previews

struct ImportBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        ImportBirthdayView(store: .demo)
            .preferredColorScheme(.light)

        ImportBirthdayView(store: .demo)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .preferredColorScheme(.light)
    }
}
