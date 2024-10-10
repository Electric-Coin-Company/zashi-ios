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
    @Perception.Bindable var store: StoreOf<ImportWallet>
    @FocusState public var isFocused: Bool

    public init(store: StoreOf<ImportWallet>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                ZashiIcon()

                Text(L10n.ImportWallet.Birthday.title)
                    .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                    .foregroundColor(Asset.Colors.primary.color)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)

                Text(L10n.ImportWallet.optionalBirthday)

                TextField("", text: store.bindingForRedactableBirthday(store.birthdayHeight))
                    .frame(height: 40)
                    .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                    .focused($isFocused)
                    .keyboardType(.numberPad)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .overlay {
                        Asset.Colors.primary.color
                            .frame(height: 1)
                            .offset(x: 0, y: 20)
                            .padding(.horizontal, 30)
                    }
                    .onAppear {
                        isFocused = true
                    }
                
                Spacer()

                ZashiButton(L10n.ImportWallet.Button.restoreWallet) {
                    store.send(.restoreWallet)
                }
                .disabled(!store.isValidForm)
                .padding(.bottom, 50)
            }
            .scrollableWhenScaledUp()
            .onAppear(perform: { store.send(.onAppear) })
            .zashiBack()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
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
