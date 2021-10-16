//
//  Pie.swift
//  Zircles
//
//  Created by Francisco Gindre on 6/19/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

struct Pie<Content: View>: View {
    @Binding var isToggled: Bool
    var cornerRadius: CGFloat
    var padding: CGFloat
    let content: Content
    init(isOn: Binding<Bool>, cornerRadius: CGFloat = 25, padding: CGFloat = 30, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self._isToggled = isOn
        self.content = content()
    }
    var body: some View {
        Toggle(isOn: $isToggled) {
            content
        }
        .toggleStyle(SimpleToggleStyle(shape: Circle(), padding: padding))
    }
}

struct Pie_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            VStack(spacing: 20) {
                Pie(isOn: .constant(true)) {
                    Text("hello")
                    .padding()
                }
                Pie(isOn: .constant(false)) {
                    Text("good bye")
                    .padding()
                }
                Pie(isOn: .constant(true)) {
                    Pie(isOn: .constant(false)) {
                                      Text("good bye")
                                      .padding()
                                  }
                }
            }
        }
    }
}
