//
//  CheckboxToggleStyle.swift
//
//
//  Created by Lukáš Korba on 05.10.2023.
//

import SwiftUI

public struct CheckboxToggleStyle: ToggleStyle {
    public init() { }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                if configuration.isOn {
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                } else {
                    Image(systemName: "square")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
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
    @State var isOn = true
    @State var isOff = false

    return VStack {
        Toggle("toggle on", isOn: $isOn)
            .toggleStyle(CheckboxToggleStyle())

        Toggle("toggle off", isOn: $isOff)
            .toggleStyle(CheckboxToggleStyle())
    }
}
