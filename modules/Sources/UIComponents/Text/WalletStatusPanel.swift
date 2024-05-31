//
//  WalletStatusPanel.swift
//
//
//  Created by Lukáš Korba on 18.12.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Combine
import WalletStatusPanel

public struct WalletStatusPanelModifier: ViewModifier {
    public enum Background {
        case pattern
        case solid
        case transparent
    }
    
    let hidden: Bool
    @Dependency(\.walletStatusPanel) var walletStatusPanel
    let background: Background
    @State private var status = WalletStatus.none
    @State private var cancellable: AnyCancellable?
    @Binding public var restoringStatus: WalletStatus

    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .onAppear {
                    cancellable = walletStatusPanel.value().sink {
                        status = $0
                        if $0 != .disconnected {
                            restoringStatus = $0
                        }
                    }
                }
                .onDisappear {
                    cancellable?.cancel()
                }
                .zIndex(0)
            
            if status != .none && !hidden {
                if background == .pattern {
                    WalletStatusPanel(text: status.text())
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                        .background(
                            Asset.Assets.gridTile.image
                                .resizable(resizingMode: .tile)
                        )
                        .zIndex(1)
                } else {
                    WalletStatusPanel(text: status.text())
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                        .background(
                            background == .transparent
                            ? .clear
                            : Asset.Colors.background.color
                        )
                        .zIndex(1)
                }
            }
        }
    }
}

extension View {
    public func walletStatusPanel(
        _ hidden: Bool = false,
        background: WalletStatusPanelModifier.Background = .solid,
        restoringStatus: Binding<WalletStatus> = Binding.constant(.none)
    ) -> some View {
        modifier(
            WalletStatusPanelModifier(hidden: hidden, background: background, restoringStatus: restoringStatus)
        )
    }
}

private struct WalletStatusPanel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.custom(FontFamily.Archivo.semiBold.name, size: 12))
            .foregroundStyle(Asset.Colors.restoreUI.color)
    }
}

#Preview {
    NavigationView {
        ScrollView{
            Text("Hello, World")
        }
        .padding(.vertical, 1)
        .walletStatusPanel()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Text("M")
        )
        .zashiTitle {
            Text("Title")
        }
    }
}
