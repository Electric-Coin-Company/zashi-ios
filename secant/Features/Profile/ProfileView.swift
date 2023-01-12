import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    let store: ProfileStore

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                qrCodeUA(viewStore.unifiedAddress)
                    .padding(.top, 30)
                
                Text("Your UA address \(viewStore.unifiedAddress)")
                    .truncationMode(.middle)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(30)

                Button(
                    action: { viewStore.send(.updateDestination(.addressDetails)) },
                    label: { Text("See address details") }
                )
                .activeButtonStyle
                .frame(height: 50)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 50, trailing: 30))

                Rectangle()
                    .frame(height: 1.5)
                    .padding(EdgeInsets(top: 0, leading: 100, bottom: 20, trailing: 100))
                    .foregroundColor(Asset.Colors.TextField.Underline.purple.color)

                Button(
                    action: { viewStore.send(.updateDestination(.settings)) },
                    label: { Text("Settings") }
                )
                .primaryButtonStyle
                .frame(height: 50)
                .padding(EdgeInsets(top: 30, leading: 30, bottom: 20, trailing: 30))

                Button(
                    action: { },
                    label: { Text("Support") }
                )
                .primaryButtonStyle
                .frame(height: 50)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 20, trailing: 30))

                Spacer()
                
                HStack {
                    VStack {
                        Text("secant v\(viewStore.appVersion)(\(viewStore.appBuild))")
                        Text("sdk v\(viewStore.sdkVersion)")
                    }
                    Spacer()
                    Button(
                        action: { },
                        label: {
                            Text("More info")
                                .foregroundColor(Asset.Colors.Text.moreInfoText.color)
                        }
                    )
                }
                .padding(30)
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
            .navigationLinkEmpty(
                isActive: viewStore.bindingForSettings,
                destination: {
                    SettingsView(store: store.settingsStore())
                }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForAddressDetails,
                destination: {
                    AddressDetailsView(store: store.addressStore())
                }
            )
        }
        .applyScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ProfileView {
    func qrCodeUA(_ qrText: String) -> some View {
        Group {
            if let img = QRCodeGenerator.generate(from: qrText) {
                Image(img, scale: 1, label: Text(String(format: NSLocalizedString("QR Code for %@", comment: ""), "\(qrText)") ))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 25)
                        .scaleEffect(1.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 8)
                        .scaleEffect(1.1)
                    )
            } else {
                Image(systemName: "qrcode")
            }
        }
    }
}

// MARK: - Previews

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(
                store: .init(
                    initialState: .init(
                        addressDetailsState: .placeholder,
                        settingsState: .placeholder
                    ),
                    reducer: ProfileReducer()
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}
