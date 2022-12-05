//
//  Drawer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 19.04.2022.
//

import SwiftUI

enum DrawerOverlay {
    case full
    case partial
    case bottom
}

struct Drawer<Content: View>: View {
    @GestureState private var translation: CGFloat = 0
    @Binding var overlay: DrawerOverlay
    
    let maxHeight: CGFloat
    let content: Content
    
    private var offset: CGFloat {
        switch overlay {
        case .full: return 70.0
        case .partial: return maxHeight - 230.0
        case .bottom: return maxHeight
        }
    }
    
    init(overlay: Binding<DrawerOverlay>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self._overlay = overlay
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    RoundedRectangle(cornerRadius: 16.0)
                        .fill(Color.secondary)
                        .opacity(0.2)
                        .frame(
                            width: 50,
                            height: 6
                        )
                        .padding(.top, 10)
                    
                    content
                }
            }
            .frame(width: proxy.size.width, height: maxHeight, alignment: .top)
            .applyScreenBackground()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16.0)
            .frame(height: proxy.size.height, alignment: .bottom)
            .offset(y: max(offset + translation, 0))
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    let snapDistanceFull = maxHeight * 0.55
                    let snapDistancePartial = maxHeight * 0.8
                    
                    if value.location.y <= snapDistanceFull {
                        overlay = .full
                    } else if value.location.y > snapDistanceFull && value.location.y <= snapDistancePartial {
                        overlay = .partial
                    } else {
                        overlay = .bottom
                    }
                }
            )
        }
        .shadow(color: Asset.Colors.Shadow.drawerShadow.color, radius: 15.0, x: 0.0, y: -4.0)
    }
}

struct Drawer_Previews: PreviewProvider {
    static var previews: some View {
        @State var overlay: DrawerOverlay = .partial
        
        return Drawer(overlay: $overlay, maxHeight: 800.0) {
            VStack {
                Text("Transaction History")

                Spacer()
            }
        }
    }
}
