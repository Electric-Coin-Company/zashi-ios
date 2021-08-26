//
//  PlainButton.swift
//  secant
//
//  Created by Francisco Gindre on 8/9/21.
//

import SwiftUI

struct PlainButton: ButtonStyle {
    enum Theme {
        case light
        case bold
    }
    
    var style = Theme.bold
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(style.foregroundColor)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
            .background(style.background)
    }
}

struct PlainButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
            .buttonStyle(PlainButton())
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
            .buttonStyle(PlainButton(style: .bold))
        }
        .padding(.horizontal, 30)
    }
}

extension PlainButton.Theme {
    var background: some View {
        switch self {
        case .bold:
            return Color.black
        default:
            return Color.white
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .bold:
            return Color.white
        default:
            return Color.black
        }
    }
}
