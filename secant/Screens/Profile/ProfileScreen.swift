//
//  ProfileScreenScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol ProfileScreenRouter: AnyObject {
}

struct ProfileScreen: View {
    @State var router: ProfileScreenRouter?
    
    @ObservedObject var viewModel: ProfileScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProfileScreenPreviews: PreviewProvider {
    static var previews: some View {
        ProfileScreen(viewModel: ProfileScreenViewModel(services: MockServices()))
    }
}
