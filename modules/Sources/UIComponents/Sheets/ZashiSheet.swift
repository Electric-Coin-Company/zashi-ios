//
//  ZashiSheet.swift
//  modules
//
//  Created by Lukáš Korba on 31.03.2025.
//

import SwiftUI
import Generated

public extension View {
    @ViewBuilder
    func heightChangePreference(_ completion: @escaping (CGFloat) -> Void) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ContentHeightKey.self, value: geometry.size.height)
                        .onPreferenceChange(ContentHeightKey.self) { height in
                            completion(height)
                        }
                }
            }
    }
}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

public struct ZashiSheetModifier<SheetContent: View>: ViewModifier {
    @Binding public var isPresented: Bool
    @State var sheetHeight: CGFloat = .zero
    var sheetContent: SheetContent

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                if #available(iOS 16.4, *) {
                    mainBody()
                        .id(sheetHeight)
                        .presentationDetents([.height(sheetHeight)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(Design.Radius._4xl)
                } else if #available(iOS 16.0, *) {
                    mainBody()
                        .id(sheetHeight)
                        .presentationDetents([.height(sheetHeight)])
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

            sheetContent
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        sheetHeight = proxy.size.height
                    }
            }
        }
    }
}

extension View {
    public func zashiSheet(isPresented: Binding<Bool>, content: @escaping () -> some View) -> some View {
        modifier(
            ZashiSheetModifier(isPresented: isPresented, sheetContent: content())
        )
    }
}
