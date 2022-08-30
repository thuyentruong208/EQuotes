//
//  DIContainer.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI
import Combine


struct DIContainer: EnvironmentKey {

    let appStateStore: Store<AppState>
    let interactors: Interactors

    init(appStateStore: Store<AppState>, interactors: Interactors) {
        self.appStateStore = appStateStore
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors = .stub) {
        self.init(appStateStore: Store<AppState>(appState),
                  interactors: interactors)
    }

    static var defaultValue: Self { Self.default }

    private static let `default` = Self(appState: AppState())

}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension View {

    func inject(_ container: DIContainer) -> some View {
        self
            .environment(\.injected, container)
    }
}
