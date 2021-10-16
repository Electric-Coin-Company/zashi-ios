//
//  ZircleOptionSelector.swift
//  Zircles
//
//  Created by Francisco Gindre on 6/24/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI
import Combine
struct ZircleOptionSelector: View {
    @Binding var optionSelected: Int
    var optionNames: [String]
    init(selection: Binding<Int>,_ options: String...) {
        self._optionSelected = selection
        self.optionNames = options
    }
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0 ..< optionNames.count) { optionIndex in
                Toggle(isOn: .constant(optionIndex == optionSelected)) {
                Text(optionNames[optionIndex])
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .shadow(color:Color(.sRGBLinear, red: 0.2, green: 0.2, blue: 0.2, opacity: 0.3), radius: 1, x: 0, y: 2)
                    .foregroundColor(optionIndex == optionSelected ? Asset.Colors.Buttons.primaryButton.color : Asset.Colors.Text.button.color)
                    .padding(.horizontal, 8)
                    .frame(minWidth: 65, idealWidth: 100, maxWidth: .infinity, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                }
                .toggleStyle(
                    GlowingToggleStyle(
                        shape: RoundedRectangle(cornerRadius: 15, style: .continuous),
                        padding: 10, onToggle: {
                            self.optionSelected = optionIndex
                        })
                )
                
            }
        }
    }
}

extension Color {
    static let background = Color(#colorLiteral(red: 0.8941176471, green: 0.9411764706, blue: 0.9568627451, alpha: 1))
}
struct ZircleOptionSelector_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color.background
                VStack(spacing: 100) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available Options")
                            .fontWeight(.heavy)
                            .foregroundColor(Asset.Colors.Text.button.color)
                            .padding(.horizontal,10)
                        ZircleOptionSelector(selection: .constant(1), "Daily","weekly","Monthly")
                            .padding(.all, 10)
                    }
                    .frame(height: 100)
                    .padding(0)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End Date")
                            .fontWeight(.heavy)
                            .foregroundColor(Asset.Colors.Text.button.color)
                            .padding(.horizontal,10)
                        ZircleOptionSelector(selection: .constant(1), "Set Date","At Will")
                            .padding(.all, 10)
                    }
                    .frame(height: 100)
                    .padding(0)

                }.padding(.all, 20)



            }
            ZStack {
                VStack(spacing: 100) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available Options")
                            .fontWeight(.heavy)
                            .foregroundColor(Asset.Colors.Text.button.color)
                            .padding(.horizontal,10)
                        ZircleOptionSelector(selection: .constant(1), "Daily","weekly","Monthly")
                            .padding(.all, 10)
                    }
                    .frame(height: 100)
                    .padding(0)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End Date")
                            .fontWeight(.heavy)
                            .foregroundColor(Asset.Colors.Text.button.color)
                            .padding(.horizontal,10)
                        ZircleOptionSelector(selection: .constant(1), "Set Date","At Will")
                            .padding(.all, 10)
                    }
                    .frame(height: 100)
                    .padding(0)

                }.padding(.all, 20)



            }
        }
    }
}



struct GlowingButtonStyle<S :Shape>: ButtonStyle {
    var shape: S
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(shape)
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                shape
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                shape
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
                    } else {
                        shape
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
            )
    }
}
