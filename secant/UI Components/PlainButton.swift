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
        
        var background: some View {
            switch self {
            case .bold: return Color.black
            default:    return Color.white
            }
        }

        var foregroundColor: Color {
            switch self {
            case .bold: return Color.white
            default:    return Color.black
            }
        }
    }

    var style = Theme.light

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(style.foregroundColor)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
            .background(style.background)
    }
}

// MARK: - Previews

struct PlainButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: {}, label: {
                Text("Button")
            })
            .buttonStyle(PlainButton())

            Button(action: {}, label: {
                Text("Button")
            })
            .buttonStyle(PlainButton(style: .bold))
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Theme

extension PlainButton.Theme {
    
}
