//
//  ZashiToggle.swift
//
//
//  Created by Lukáš Korba on 04-16-2024.
//

import SwiftUI
import Generated

public struct ZashiToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    public init(isOn: Binding<Bool>, label: String) {
        self._isOn = isOn
        self.label = label
    }
    
    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Toggle(isOn: $isOn, label: {
                Text(label)
                    .font(.custom(FontFamily.Inter.medium.name, size: 14))
            })
            .toggleStyle(CheckboxToggleStyle())
        }
        .foregroundColor(Asset.Colors.primary.color)
    }
}

#Preview {
    BoolStateWrapper(initialValue: false) {
        ZashiToggle(isOn: $0, label: "I acknowledge")
    }
}
