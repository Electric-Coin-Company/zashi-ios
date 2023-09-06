//
//  File.swift
//  
//
//  Created by Praveen kumar Vattipalli on 02/09/23.
//

import Foundation
import SwiftUI
import Generated

struct CustomNavigationButton: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                            Text(L10n.General.back.uppercased())
                                .foregroundColor(.black)
                        }
                    }
                }
            }
    }
}
