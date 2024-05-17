//
//  WhatsNewStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024
//

import ComposableArchitecture
import WhatsNewProvider

@Reducer
public struct WhatsNew {
    @ObservableState
    public struct State: Equatable {
        public var latest: WhatNewRelease
        public var releases: WhatNewReleases

        public init(
            latest: WhatNewRelease = .zero,
            releases: WhatNewReleases = .zero
        ) {
            self.latest = latest
            self.releases = releases
        }
    }
    
    public enum Action: Equatable {
        case onAppear
    }
    
    @Dependency(\.whatsNewProvider) var whatsNewProvider
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.latest = whatsNewProvider.latest()
                state.releases = whatsNewProvider.all()
                return .none
            }
        }
    }
}
