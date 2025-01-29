//
//  AnnotationSheet.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-27.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension TransactionDetailsView {
    @ViewBuilder func annotationContent(_ isEditMode: Bool) -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.0, *) {
                mainBodyUM(isEditMode: isEditMode)
                    .presentationDetents([.height(filtersSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                mainBodyUM(isEditMode: isEditMode, stickToBottom: true)
            }
        }
    }

    @ViewBuilder func mainBodyUM(isEditMode: Bool, stickToBottom: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if stickToBottom {
                Spacer()
            }
            
            Text(isEditMode
                 ? L10n.Annotation.edit
                 : L10n.Annotation.addArticle
            )
            .zFont(.semiBold, size: 20, style: Design.Text.primary)
            .padding(.top, 32)
            .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                TextEditor(text: $store.annotation)
                    .focused($isAnnotationFocused)
                    .font(.custom(FontFamily.Inter.medium.name, size: 16))
                    .frame(height: 122)
                    .padding(.horizontal, 10)
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                    .colorBackground(Design.Inputs.Default.bg.color(colorScheme))
                    .cornerRadius(10)
                    .overlay {
                        if store.annotation.isEmpty {
                            HStack {
                                VStack {
                                    Text(L10n.Annotation.placeholder)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 16))
                                        .zForegroundColor(Design.Inputs.Default.text)
                                        .onTapGesture {
                                            isAnnotationFocused = true
                                        }

                                    Spacer()
                                }
                                .padding(.top, 10)
                                
                                Spacer()
                            }
                            .padding(.leading, 14)
                        } else {
                            EmptyView()
                        }
                    }

                Text(L10n.Annotation.chars(store.annotation.count, TransactionDetails.State.Constants.annotationMaxLength))
                    .zFont(size: 14, style: Design.Inputs.Default.hint)
            }
            .padding(.bottom, 32)
            
            if isEditMode {
                HStack(spacing: 8) {
                    ZashiButton(
                        L10n.Annotation.delete,
                        type: .destructive1
                    ) {
                        store.send(.deleteNoteTapped)
                    }

                    ZashiButton(
                        L10n.Annotation.save,
                        type: .secondary
                    ) {
                        store.send(.saveNoteTapped)
                    }
                    .disabled(store.annotation == store.annotationOrigin)
                }
                .padding(.bottom, 24)
            } else {
                ZashiButton(
                    L10n.Annotation.add,
                    type: .secondary
                ) {
                    store.send(.addNoteTapped)
                }
                .disabled(store.annotation.isEmpty)
                .padding(.bottom, 24)
            }
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
