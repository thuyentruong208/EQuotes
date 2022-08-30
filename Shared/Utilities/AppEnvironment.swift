//
//  AppEnvironment.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation
import Combine
import Firebase

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        FirebaseApp.configure()

        Auth.auth().signInAnonymously() { _, error in
            if let error = error {
                print(error)
                return
            }
        }

        let appState = AppState()

        let interactors = Interactors(quotesInteractor: RealEQuotesInteractor(appState: appState))

        let diContainer = DIContainer(appState: appState, interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

}
