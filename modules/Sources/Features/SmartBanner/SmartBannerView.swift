//
//  SmartBannerView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-14.
//

import SwiftUI
import ComposableArchitecture

import Generated
import Generated
import UIComponents

enum SBConstants {
    static let fixedHeight: CGFloat = 32
    static let fixedHeightWithShadow: CGFloat = 36
    static let shadowHeight: CGFloat = 4
}

public struct SmartBannerView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<SmartBanner>
    
    @State private var realHeight: CGFloat = 100
    @State private var isUnhidden = false
    @State private var height: CGFloat = 0

    public init(store: StoreOf<SmartBanner>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .top) {
                BottomRoundedRectangle(radius: SBConstants.fixedHeight)
                    .frame(height: SBConstants.fixedHeight)
                    .foregroundColor(Design.screenBackground.color(colorScheme))
                    .shadow(color: Design.Text.primary.color(colorScheme).opacity(0.25), radius: 1)
                    .zIndex(1)
                
                VStack(spacing: 0) {
                    if store.isOpen {
                        priorityContent()
                            .padding(.vertical, 16)
                            .padding(.top, SBConstants.fixedHeight)
                            .onTapGesture {
                                store.send(.smartBannerContentTapped)
                            }
                            .screenHorizontalPadding()
                    }
                    
                    TopRoundedRectangle(radius: store.isOpen ? SBConstants.fixedHeight : 0)
                        .frame(height: SBConstants.fixedHeightWithShadow)
                        .foregroundColor(Design.screenBackground.color(colorScheme))
                        .shadow(color: Design.Text.primary.color(colorScheme).opacity(0.1), radius: store.isOpen ? 1 : 0, y: -1)
                }
                .frame(minHeight: SBConstants.fixedHeight + SBConstants.shadowHeight)
                
                shareMessageView()
            }
            .zashiSheet(isPresented: $store.isSmartBannerSheetPresented) {
                helpSheetContent()
                    .screenHorizontalPadding()
            }
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
            .background {
                VStack(spacing: 0) {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Design.Utility.Purple._700.color(.light), location: 0.00),
                            Gradient.Stop(color: Design.Utility.Purple._950.color(.light), location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0.0),
                        endPoint: UnitPoint(x: 0.5, y: 1.0)
                    )
                    Design.screenBackground.color(colorScheme)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
            .clipShape( Rectangle() )
        }
    }
}

extension SmartBannerView {
    @ViewBuilder func shareMessageView() -> some View {
        if let message = store.messageToBeShared {
            UIShareDialogView(activityItems: [message]) {
                store.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Store

extension SmartBanner {
    public static var initial = StoreOf<SmartBanner>(
        initialState: .initial
    ) {
        SmartBanner()
    }
}

// MARK: - Placeholders

extension SmartBanner.State {
    public static let initial = SmartBanner.State()
}

// MARK: - Helpers

struct BottomRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height - radius))

            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: height),
                control: CGPoint(x: width, y: height)
            )
            
            path.addLine(to: CGPoint(x: radius, y: height))

            path.addQuadCurve(
                to: CGPoint(x: 0, y: height - radius),
                control: CGPoint(x: 0, y: height)
            )
            
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: radius))

            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: 0),
                control: CGPoint(x: width, y: 0)
            )
            
            path.addLine(to: CGPoint(x: radius, y: 0))

            path.addQuadCurve(
                to: CGPoint(x: 0, y: radius),
                control: CGPoint(x: 0, y: 0)
            )
            
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}
