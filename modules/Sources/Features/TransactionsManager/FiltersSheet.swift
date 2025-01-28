//
//  FiltersSheet.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-24.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct FilterView: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let active: Bool
    let action: () -> Void
    
    public init(
        title: String,
        active: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.active = active
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            if active {
                HStack(spacing: 4) {
                    Text(title)
                        .zFont(.semiBold, size: 14, style: Design.Btns.Secondary.fg)
                        .lineLimit(1)
                    
                    Asset.Assets.buttonCloseX.image
                        .zImage(size: 20, style: Design.Btns.Secondary.fg)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Design.Btns.Secondary.bg.color(colorScheme))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Design.Btns.Secondary.border.color(colorScheme))
                        }
                }
            } else {
                Text(title)
                    .zFont(.semiBold, size: 14, style: Design.Btns.Tertiary.fg)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                    }
            }
        }
    }
}

extension TransactionsManagerView {
    @ViewBuilder func filtersContent() -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.0, *) {
                mainBody()
                    .presentationDetents([.height(filtersSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                mainBody(stickToBottom: true)
            }
        }
    }
    
    @ViewBuilder func mainBody(stickToBottom: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if stickToBottom {
                Spacer()
            }
            
            Text("Filter")
                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                .padding(.top, 32)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    FilterView(title: "Sent", active: store.isSentFilterActive) { store.send(.toggleFilter(.sent)) }
                    FilterView(title: "Received", active: store.isReceivedFilterActive) { store.send(.toggleFilter(.received)) }
                    FilterView(title: "Memos", active: store.isMemosFilterActive) { store.send(.toggleFilter(.memos)) }
                }
                
                HStack(spacing: 8) {
                    FilterView(title: "Notes", active: store.isNotesFilterActive) { store.send(.toggleFilter(.notes)) }
                    FilterView(title: "Bookmarked", active: store.isBookmarkedFilterActive) { store.send(.toggleFilter(.bookmarked)) }
                }
                
                HStack(spacing: 8) {
                    FilterView(title: "Contact", active: store.isContactFilterActive) { store.send(.toggleFilter(.contact)) }
                }
            }
            .padding(.bottom, 32)
            
            HStack(spacing: 12) {
                ZashiButton(
                    "Reset",
                    type: .secondary
                ) {
                    store.send(.resetFiltersTapped)
                }
                
                ZashiButton(
                    "Apply"
                ) {
                    store.send(.applyFiltersTapped)
                }
            }
            .padding(.bottom, 24)
        }
        .screenHorizontalPadding()
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        filtersSheetHeight = proxy.size.height
                    }
            }
        }
    }
}
