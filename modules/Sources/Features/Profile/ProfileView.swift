import ComposableArchitecture
import SwiftUI
import Generated
import AddressDetails
import Utils
import UIComponents

public struct ProfileView: View {
    let store: ProfileStore

    public init(store: ProfileStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                qrCodeUA(viewStore.unifiedAddress)
                    .padding(.vertical, 50)

                HStack {
                    Text(L10n.ReceiveZec.yourAddress)
                        .fontWeight(.bold)
                        .onTapGesture {
                            viewStore.send(.copyUnifiedAddressToPastboard)
                        }

                    Button {
                        viewStore.send(.updateDestination(.addressDetails))
                    } label: {
                        Image(systemName: "info.circle")
                            .padding(15)
                            .tint(.black)
                    }
                    .offset(x: -20, y: -10)
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
    public func qrCodeUA(_ qrText: String) -> some View {
        Group {
            if let img = QRCodeGenerator.generate(from: qrText) {
                Image(img, scale: 1, label: Text(L10n.qrCodeFor(qrText)))
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
