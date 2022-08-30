//
//  EQuotesApp.swift
//  Shared
//
//  Created by Thuyên Trương on 29/08/2022.
//

import SwiftUI

@main
struct EQuotesApp: App {

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            EQuoteView()
                .inject(appDelegate.environment.container)
                .environmentObject(appDelegate.environment.container.appState.quoteState)
        }
    }
}
