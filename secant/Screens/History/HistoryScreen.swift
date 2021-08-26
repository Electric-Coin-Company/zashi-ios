//
//  HistoryScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol HistoryScreenRouter: AnyObject {
}

struct HistoryScreen: View {
    @State var router: HistoryScreenRouter?
    
    @ObservedObject var viewModel: HistoryScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HistoryScreenPreviews: PreviewProvider {
    static var previews: some View {
        HistoryScreen(viewModel: HistoryScreenViewModel(services: MockServices()))
    }
}
