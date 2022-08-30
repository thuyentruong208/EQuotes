//
//  DIContainer.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI
import Combine


struct DIContainer: EnvironmentKey {

    let appState: AppState
    let interactors: Interactors

    init(appState: AppState, interactors: Interactors = .stub) {
        self.appState = appState
        self.interactors = interactors
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
