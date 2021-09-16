//
//  ProfileScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol ProfileScreenRouter: AnyObject {}

struct ProfileScreen: View {
    @ObservedObject var viewModel: ProfileScreenViewModel

    @State var router: ProfileScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct ProfileScreenPreviews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(viewModel: ProfileScreenViewModel(services: MockServices()))
    }
}
