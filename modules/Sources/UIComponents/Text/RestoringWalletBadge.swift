//
//  RestoringWalletBadge.swift
//  
//
//  Created by Lukáš Korba on 18.12.2023.
//

import SwiftUI
import Generated

public struct RestoringWalletBadgeModifier: ViewModifier {
    public enum Background {
        case pattern
        case solid
        case transparent
    }
    
    let isOn: Bool
    let background: Background

    public func body(content: Content) -> some View {
        if isOn {
            ZStack(alignment: .top) {
                content
                    .zIndex(0)
                
                if background == .pattern {
                    RestoringWalletBadge()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                        .background(
                            Asset.Assets.gridTile.image
                                .resizable(resizingMode: .tile)
                        )
                        .zIndex(1)
                } else {
                    RestoringWalletBadge()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                        .background(
                            background == .transparent
                            ? .clear
                            : Asset.Colors.secondary.color
                        )
                        .zIndex(1)
                }
            }
        } else {
            content
        }
    }
}

extension View {
    public func restoringWalletBadge(
        isOn: Bool,
        background: RestoringWalletBadgeModifier.Background = .solid
    ) -> some View {
        modifier(
            RestoringWalletBadgeModifier(isOn: isOn, background: background)
        )
    }
}

private struct RestoringWalletBadge: View {
    var body: some View {
        Text(L10n.General.restoringWallet)
            .font(.custom(FontFamily.Archivo.semiBold.name, size: 12))
            .foregroundStyle(Asset.Colors.shade55.color)
    }
}

#Preview {
    NavigationView {
        ScrollView{
            Text("Hello, World")
        }
        .padding(.vertical, 1)
        .restoringWalletBadge(isOn: true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Text("M")
        )
        .zashiTitle {
            Text("Title")
        }
    }
}
