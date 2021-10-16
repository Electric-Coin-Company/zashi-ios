import SwiftUI

extension Color {
    static let offWhite = Color(red: 228 / 255, green: 240 / 255, blue: 250 / 255)

    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)

    static let lightStart = Color(red: 60 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 30 / 255, green: 80 / 255, blue: 120 / 255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
                    } else {
                        Circle()
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
            )
    }
}
struct SimpleBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.offWhite)
                    .overlay(
                        shape
                            .stroke(Color.gray, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(shape.fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        shape
                            .stroke(Color.white, lineWidth: 8)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(shape.fill(LinearGradient(Color.clear, Color.black)))
                    )
            } else {
                shape
                    .fill(Color.offWhite)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
        }
    }
}

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                    .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(Color.darkEnd, lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            }
        }
    }
}

struct ColorfulBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.lightEnd, Color.lightStart))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(LinearGradient(Color.lightStart, Color.lightEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            }
        }
    }
}

struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                DarkBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
            .animation(nil)
    }
}

struct DarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        }
        .background(
            DarkBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct ColorfulButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                ColorfulBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
            .animation(nil)
    }
}
struct SimpleToggleStyle<S :Shape>: ToggleStyle {
    let shape: S
    var padding: CGFloat = 30
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .contentShape(shape)
                .padding(padding)
        }
        .background(
            SimpleBackground(isHighlighted: configuration.isOn, shape: shape)
        )
    }
}
extension LinearGradient {
    static var zButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Asset.Colors.ProgressIndicator.gradientLeft.color, Asset.Colors.ProgressIndicator.gradientRight.color]),
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5))
    }
}


struct GlowingBackground<S: Shape>: View {

    var shape: S
    var body: some View {
        shape
            .fill(LinearGradient.zButtonGradient)
            .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.3), radius: 15, x: 10, y: 15)
            .glow(vibe: .cool, soul: .split(left: Asset.Colors.ProgressIndicator.gradientLeft.color, right: Asset.Colors.ProgressIndicator.gradientLeft.color))
            .shadow(color: Color.white.opacity(0.5), radius: 25, x:-10, y: -10)
    }

}

struct ColorfulToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(30)
                .contentShape(RoundedRectangle(cornerRadius: 5))
        }
        .background(
            ColorfulBackground(isHighlighted: configuration.isOn, shape: RoundedRectangle(cornerRadius: 5))
        )
    }
}

struct GlowingToggleStyle<S :Shape>: ToggleStyle {
    let shape: S
    var padding: CGFloat = 30
    var onToggle: (() -> ())?
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
            onToggle?()
        }) {
            configuration.label
                .contentShape(shape)
                .padding(padding)
        }
        .background(
            backgroundViewIf(isOn: configuration.isOn)
        )
    }
    
    func backgroundViewIf(isOn: Bool) -> AnyView {
        if isOn {
            return AnyView(
                GlowingBackground(shape: shape)
            )
        } else {
            return AnyView(
                SimpleBackground(isHighlighted: false, shape: shape)
            )
        }
    }
}

struct NeumorphicContentView: View {
    @State private var isToggled = false

    var body: some View {
        VStack {
            ZStack {
                LinearGradient(Color.darkStart, Color.darkEnd)

                VStack(spacing: 40) {
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(ColorfulButtonStyle())

                    Toggle(isOn: $isToggled) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(ColorfulToggleStyle())
                }
            }
            ZStack {
                Color.offWhite

                VStack(spacing: 40) {
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(SimpleButtonStyle())

                    Toggle(isOn: $isToggled) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.gray)
                    }
                    .toggleStyle(GlowingToggleStyle(shape: RoundedRectangle(cornerRadius: 5, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)))
                }
            }
        }
        
        .edgesIgnoringSafeArea(.all)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        NeumorphicContentView()
    }
}
