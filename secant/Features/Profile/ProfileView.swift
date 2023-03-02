import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    let store: ProfileStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                qrCodeUA(viewStore.unifiedAddress)
                    .padding(.vertical, 50)

                HStack {
                    Text("Your UA")
                        .fontWeight(.bold)
                        .onTapGesture {
                            viewStore.send(.copyUnifiedAddressToPastboard)
                        }

                    Button {
                        viewStore.send(.updateDestination(.addressDetails))
                    } label: {
                        Image(systemName: "info.circle")
                            .offset(x: -10, y: -10)
                            .tint(.black)
                    }
                }
                
                Text("\(viewStore.unifiedAddress)")
                    .padding(30)
                
                Spacer()
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
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
                    initialState: .init(addressDetailsState: .placeholder),
                    reducer: ProfileReducer()
                )
            )
        }
        .preferredColorScheme(.light)
    }
}
