//
//  SendRejectSheet.swift
//  modules
//
//  Created by Lukáš Korba on 11.02.2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension SignWithKeystoneView {
    @ViewBuilder func rejectSendContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.4, *) {
                mainBody(colorScheme: colorScheme)
                    .presentationDetents([.height(accountSwitchSheetHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Design.CornerRadius.sheet)
            } else if #available(iOS 16.0, *) {
                mainBody(colorScheme: colorScheme)
                    .presentationDetents([.height(accountSwitchSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                mainBody(stickToBottom: true, colorScheme: colorScheme)
            }
        }
    }
    
    @ViewBuilder func mainBody(stickToBottom: Bool = false, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 0) {
            if stickToBottom {
               Spacer()
            }

            Asset.Assets.Icons.arrowUp.image
                .zImage(size: 20, style: Design.Utility.ErrorRed._500)
                .background {
                    Circle()
                        .fill(Design.Utility.ErrorRed._100.color(colorScheme))
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 48)
                .padding(.bottom, 20)

            Text(L10n.KeystoneTransactionReject.title)
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.bottom, 8)

            Text(L10n.KeystoneTransactionReject.msg)
                .zFont(size: 14, style: Design.Text.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            ZashiButton(L10n.KeystoneTransactionReject.goBack) {
                store.send(.rejectRequestCanceled)
            }
            .padding(.bottom, 8)
            
            ZashiButton(
                L10n.KeystoneTransactionReject.rejectSig,
                type: .destructive2
            ) {
                store.send(.rejectTapped)
            }
            .padding(.bottom, 24)
        }
        .screenHorizontalPadding()
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        accountSwitchSheetHeight = proxy.size.height
                    }
            }
        }
    }
}
