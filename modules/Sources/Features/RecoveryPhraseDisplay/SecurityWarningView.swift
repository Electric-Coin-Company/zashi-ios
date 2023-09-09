//
//  File.swift
//  
//
//  Created by Praveen kumar Vattipalli on 08/09/23.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct SecurityWarningView: View {
    let store: SecurityWarningStore
    @State var isOn = false

    public init(store: SecurityWarningStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 45) {
                VStack(alignment: .center, spacing: 45) {
                    Asset.Assets.zashiLogo.image
                        .resizable()
                        .frame(width: 33, height: 43)
                    VStack(alignment: .center, spacing: 25) {
                        Text("Security warning:")
                            .font(
                                .custom(FontFamily.Inter.bold.name, size: 25)
                                .weight(.bold)
                            )
                            .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                        Text("Zashi 0.9 is a Zcash-only shielded wallet, built by Zcashers for Zcashers. The purpose of this release is primarily to test functionality and collect feedback. While Zashi has been engineered for your privacy and safety (read the privacy policy here), this release has not yet been security audited. Users are cautioned to deposit, send, and receive only small amounts of ZEC. Please click below to proceed.")
                            .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                            .font(
                                .custom(FontFamily.Inter.regular.name, size: 16)
                                .weight(.regular)
                            )
                            .padding(.leading, 50)
                            .padding(.trailing, 50)
                    }
                    
                    
                }
                
                VStack(alignment: .leading) {
                    Toggle("I acknowledge", isOn: $isOn)
                    .padding(.leading, 50)
                    .toggleStyle(CheckboxToggleStyle())
                    .font(
                        .custom(FontFamily.Inter.regular.name, size: 14)
                        .weight(.regular)
                    )
                }
                
                Spacer()
                Button(
                    action: { viewStore.send(.debugMenuStartup) },
                    label: { Text("CONFIRM") }
                )
                .activeButtonStyle
                .frame(maxHeight: 70)
                .padding(EdgeInsets(top: 30.0, leading: 50.0, bottom: 60.0, trailing: 50.0))
            }
            .padding(.top, 0)
            .applyScreenBackground()
            .replaceNavigationBackButton()
        }
    }
}



struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
 
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 20, height: 20)
                .cornerRadius(5.0)
                .overlay {
                    Image(systemName: configuration.isOn ? "checkmark" : "")
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
 
            configuration.label
 
        }
    }
}
