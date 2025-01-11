//
//  Toast.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-18-2024.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct Toast: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public enum Edge: Equatable {
        case top(String)
        case bottom(String)
    }
    
    @Shared(.inMemory(.toast)) public var toast: Edge? = nil

    @State private var message: String? = nil
    @State private var edgeOffset: CGFloat = 20
    @State private var opacity: CGFloat = 0
    @State var top = false

    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .zIndex(0)
            
            if let message {
                VStack {
                    if !top {
                        Spacer()
                    }
                    
                    Text(message)
                        .zFont(size: 14, style: Design.Btns.Primary.fg)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Design.Btns.Primary.bg.color(colorScheme))
                        }
                    
                    if top {
                        Spacer()
                    }
                }
                .opacity(opacity)
                .screenHorizontalPadding()
                .padding(.top, top ? edgeOffset : 0)
                .padding(.bottom, top ? 0 : edgeOffset)
                .zIndex(1)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.25)) {
                        edgeOffset = 50
                        opacity = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            edgeOffset = 20
                            opacity = 0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        $toast.withLock { $0 = nil }
                        self.message = nil
                    }
                }
            }
        }
        .onChange(of: toast) { value in
            guard message == nil else { return }
            
            switch value {
            case .top(let msg):
                message = msg
                top = true
            case .bottom(let msg):
                message = msg
                top = false
            case .none: break
            }
        }
    }
}

extension View {
    public func toast() -> some View {
        modifier(
            Toast()
        )
    }
}
