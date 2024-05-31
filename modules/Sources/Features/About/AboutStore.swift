import SwiftUI
import ComposableArchitecture

import AppVersion
import Generated
import WhatsNew

@Reducer
public struct About {
    @ObservableState
    public struct State: Equatable {
        public var appVersion = ""
        public var appBuild = ""
        public var whatsNewState: WhatsNew.State
        public var whatsNewViewBinding: Bool = false

        public init(
            appVersion: String = "",
            appBuild: String = "",
            whatsNewState: WhatsNew.State,
            whatsNewViewBinding: Bool = false
        ) {
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.whatsNewState = whatsNewState
            self.whatsNewViewBinding = whatsNewViewBinding
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<About.State>)
        case onAppear
        case privacyPolicyButtonTapped
        case whatsNew(WhatsNew.Action)
        case whatsNewButtonTapped
    }

    @Dependency(\.appVersion) var appVersion

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.whatsNewState, action: /Action.whatsNew) {
            WhatsNew()
        }

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
                
            case .whatsNew:
                return .none
                
            case .whatsNewButtonTapped:
                state.whatsNewViewBinding = true
                return .none
            }
        }
    }
}
