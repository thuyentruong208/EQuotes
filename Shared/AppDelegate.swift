//
//  AppDelegate.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation


#if os(iOS)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    let environment = AppEnvironment.bootstrap()
}

#endif

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    let environment = AppEnvironment.bootstrap()
}
#endif


