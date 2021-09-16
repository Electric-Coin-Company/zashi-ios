//___FILEHEADER___

import Foundation
import SwiftUI

class ___FILEBASENAMEASIDENTIFIER___: Router {
    var services: Services

    init(services: Services) {
        self.services = services
    }

    func rootView() -> some View {
        // Add your content here
        NavigationView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}
