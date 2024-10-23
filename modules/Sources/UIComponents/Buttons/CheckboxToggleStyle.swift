//
//  CheckboxToggleStyle.swift
//
//
//  Created by Lukáš Korba on 05.10.2023.
//

import SwiftUI
import Generated

public struct CheckboxToggleStyle: ToggleStyle {
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                if configuration.isOn {
                    Image(systemName: "checkmark.square.fill")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .background {
                            Asset.Colors.background.color
                                .scaleEffect(x: 0.94, y: 0.94)
                        }
                        .foregroundColor(Asset.Colors.primary.color)
                } else {
                    Image(systemName: "square")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .background {
                            Asset.Colors.background.color
                                .scaleEffect(x: 0.94, y: 0.94)
                        }
                        .foregroundColor(Asset.Colors.primary.color)
                }
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }

            configuration.label
        }
    }
}

#Preview {
    VStack {
        BoolStateWrapper {
            Toggle("toggle on", isOn: $0)
                .toggleStyle(CheckboxToggleStyle())
        }
        
        BoolStateWrapper(initialValue: false) {
            Toggle("toggle off", isOn: $0)
                .toggleStyle(CheckboxToggleStyle())
        }
    }
    .applyScreenBackground()
    .preferredColorScheme(.dark)
}
