//
//  HistoryScreen.swift
//  secant
//
//  Created by Francisco Gindre on 8/12/21.
//

import SwiftUI

protocol HistoryScreenRouter: AnyObject {}

struct HistoryScreen: View {
    @ObservedObject var viewModel: HistoryScreenViewModel

    @State var router: HistoryScreenRouter?

    var body: some View {
        Text("Hello, World!")
    }
}

struct HistoryScreenPreviews: PreviewProvider {
    static var previews: some View {
        HistoryScreen(viewModel: HistoryScreenViewModel(services: MockServices()))
    }
}
