//
//  DeeplinkWarningView.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-12-2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct DeeplinkWarningView: View {
    @Perception.Bindable var store: StoreOf<DeeplinkWarning>
    
    public init(store: StoreOf<DeeplinkWarning>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack {
                    Text("Deeplink warning")
                        .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                        .padding(.horizontal, 35)
                        .padding(.vertical, 35)

                    Text(
                        """
                        You have scanned or followed a zcash: link representing a payment request.
                        
                        On $OS there is no way to ensure that this way of using zcash: links will reach your intended wallet app.
                        
                        If a malicious app were installed on your device, it could:
                        
                        gain information about the payment, which could then be used in social engineering attacks or to link this use of Zcash with other transactions;
                        modify the link and then pass it on to a real wallet app, which could result in you sending money to the wrong address.
                        These attack possibilities apply when scanning a QR code, following a link, or copying and pasting a link from the clipboard.
                        
                        To maintain your privacy and security, please instead manually open the Zcash wallet app that you intend to pay with, and use its scanning feature to scan QR codes. If you do this in future then it will be faster as well as more secure: you won't need to go through this screen again, and you will be safer from any malicious apps.
                        
                        For Zashi the scanner is [brief description of how to get to it].
                        
                        We can't automatically open Zashi for you because this screen could also be faked by a malicious app. Thanks for reading, and sorry for the inconvenience.
                        """
                    )
                    .font(.custom(FontFamily.Archivo.regular.name, size: 12))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 15)
                    
                    Button("I got it".uppercased()) {
                        store.send(.gotItTapped)
                    }
                    .zcashStyle()
                    .padding(.horizontal, 50)
                    .padding(.vertical, 50)
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 1)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
    }
}

// MARK: - Previews

#Preview {
    DeeplinkWarningView(store: DeeplinkWarning.initial)
}

// MARK: - Store

extension DeeplinkWarning {
    public static var initial = StoreOf<DeeplinkWarning>(
        initialState: .initial
    ) {
        DeeplinkWarning()
    }
}

// MARK: - Placeholders

extension DeeplinkWarning.State {
    public static let initial = DeeplinkWarning.State()
}
