//
//  ZashiSheet.swift
//  modules
//
//  Created by Lukáš Korba on 31.03.2025.
//

import SwiftUI

public struct ZashiSheetModifier<SheetContent: View>: ViewModifier {
    @Binding public var isPresented: Bool
    @State var sheetHeight: CGFloat = .zero
    var sheetContent: SheetContent
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                if #available(iOS 16.0, *) {
                    mainBody()
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
