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
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Design.Checkboxes.onBg.color)
                        .frame(width: 16, height: 16)
                        .overlay {
                            Asset.Assets.check.image
                                .zImage(size: 12, style: Design.Checkboxes.onFg)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Design.Checkboxes.offBg.color)
                        .frame(width: 16, height: 16)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Design.Checkboxes.offStroke.color)
                        }
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
