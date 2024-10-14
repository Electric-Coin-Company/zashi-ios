//
//  WhatsNewView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import WhatsNewProvider

public struct WhatsNewView: View {
    @Perception.Bindable var store: StoreOf<WhatsNew>
    
    public init(store: StoreOf<WhatsNew>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                HStack {
                    Text(L10n.WhatsNew.version(store.latest.version))
                        .font(.custom(FontFamily.Inter.bold.name, size: 14))
                    
                    Spacer()
                    
                    Text(store.latest.date)
                        .font(.custom(FontFamily.Inter.bold.name, size: 14))
                }
                .padding(.vertical, 25)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
                
                WithPerceptionTracking {
                    ForEach(0..<store.latest.sections.count, id: \.self) { sectionIndex in
                        VStack(alignment: .leading, spacing: 6) {
                            WithPerceptionTracking {
                                Text(store.latest.sections[sectionIndex].title)
                                    .font(.custom(FontFamily.Inter.bold.name, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                WithPerceptionTracking {
                                    ForEach(0..<store.latest.sections[sectionIndex].bulletpoints.count, id: \.self) { index in
                                        WithPerceptionTracking {
                                            if let previewText = try? AttributedString(
                                                markdown: store.latest.sections[sectionIndex].bulletpoints[index],
                                                including: \.zashiApp) {
                                                HStack {
                                                    VStack {
                                                        Circle()
                                                            .frame(width: 4, height: 4)
                                                            .padding(.top, 7)
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                    ZashiText(withAttributedString: previewText)
                                                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .accentColor(Asset.Colors.primary.color)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 35)
                }
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear { store.send(.onAppear) }
            .screenTitle(L10n.About.whatsNew)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}

// MARK: - Previews

#Preview {
    WhatsNewView(store: WhatsNew.initial)
}

// MARK: - Store

extension WhatsNew {
    public static var initial = StoreOf<WhatsNew>(
        initialState: .initial
    ) {
        WhatsNew()
    }
}

// MARK: - Placeholders

extension WhatsNew.State {
    public static let initial = WhatsNew.State(latest: .zero, releases: .zero)
}
