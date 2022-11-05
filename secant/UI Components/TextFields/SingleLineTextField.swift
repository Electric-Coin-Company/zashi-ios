//
//  SingleLineTextField.swift
//  secant-testnet
//
//  Created by Adam Stener on 2/8/22.
//

import SwiftUI
import ComposableArchitecture

struct SingleLineTextField<TitleAccessoryContent, InputPrefixContent, InputAccessoryContent>: View
    where TitleAccessoryContent: View, InputPrefixContent: View, InputAccessoryContent: View {
    let placeholderText: String
    let title: String
    let store: TCATextFieldStore

    @ViewBuilder let titleAccessoryView: TitleAccessoryContent
    @ViewBuilder let inputPrefixView: InputPrefixContent
    @ViewBuilder let inputAccessoryView: InputAccessoryContent

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.system(size: 13))

                Spacer()

                titleAccessoryView
            }

            HStack {
                inputPrefixView
                
                TCATextField(
                    placeholder: placeholderText,
                    store: store
                )

                Spacer()

                inputAccessoryView
            }
            .frame(maxHeight: 50)

            TextFieldFooter()
        }
    }
}

struct SingleLineTextField_Previews: PreviewProvider {
    struct TransactionPreview: View {
        let store: TCATextFieldStore
        let maxTransactionValue = 500.0

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    SingleLineTextField(
                        placeholderText: "$0",
                        title: "How much?",
                        store: store,
                        titleAccessoryView: {
                            Button(
                                action: {
                                    viewStore.send(.set("\(500)"))
                                },
                                label: { Text("Max") }
                            )
                            .textFieldTitleAccessoryButtonStyle
                        },
                        inputPrefixView: { EmptyView() },
                        inputAccessoryView: { EmptyView() }
                    )
                }
            }
        }
    }

    struct UserPreview: View {
        let store: TCATextFieldStore

        var body: some View {
            VStack {
                SingleLineTextField(
                    placeholderText: "",
                    title: "Who would you like to deal with really long text today?",
                    store: store,
                    titleAccessoryView: { EmptyView() },
                    inputPrefixView: { EmptyView() },
                    inputAccessoryView: { EmptyView() }
                )
            }
        }
    }

    static var previews: some View {
        TransactionPreview(
            store: TCATextFieldStore(
                initialState: .init(
                    validationType: .floatingPoint,
                    text: ""
                ),
                reducer: TCATextFieldReducer()
            )
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))

        UserPreview(
            store: TCATextFieldStore(
                initialState: .init(
                    validationType: .email,
                    text: ""
                ),
                reducer: TCATextFieldReducer()
            )
        )
        .preferredColorScheme(.light)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
