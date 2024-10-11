import SwiftUI
import ComposableArchitecture

import AppVersion
import Generated

@Reducer
public struct About {
    @ObservableState
    public struct State: Equatable {
        public var appVersion = ""
        public var appBuild = ""

        public init(
            appVersion: String = "",
            appBuild: String = ""
        ) {
            self.appVersion = appVersion
            self.appBuild = appBuild
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<About.State>)
        case onAppear
        case privacyPolicyButtonTapped
    }

    @Dependency(\.appVersion) var appVersion

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none

            case .binding:
                return .none

            case .privacyPolicyButtonTapped:
                return .none
            }
        }
    }
}
