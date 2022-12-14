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
                logger.error("Error: \(error)")
                return
            }
        }

        let appState = AppState()
        let dbManager = RealDatabaseManager()

        let interactors = Interactors(
            quotesInteractor: RealEQuotesInteractor(
                dbManager: dbManager,
                englishAPI: RealEnglishAPI(),
                appState: appState),
            helpersInteractor: RealHelpersInteractor(),
            eventsInteractor: RealEventsInteractor()
        )

        let diContainer = DIContainer(appState: appState, interactors: interactors)
        return AppEnvironment(container: diContainer)
    }

}
