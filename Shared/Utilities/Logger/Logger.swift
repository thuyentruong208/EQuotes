//
//  Logger.swift
//  EQuotes (iOS)
//
//  Created by Thuyên Trương on 07/09/2022.
//

import Logging
import Foundation

extension Logger {
    static let appLogURL = try! FileManager.default
        .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("app.log")
}

#if os(macOS)
var logger: Logger = {
    let logFileURL = Logger.appLogURL

    LoggingSystem.bootstrap { label in
        var consoleLogHandler = StreamLogHandler.standardOutput(label: label)
        consoleLogHandler.logLevel = .debug
        let handlers: [LogHandler] = [
            consoleLogHandler
        ]

       return MultiplexLogHandler(handlers)
    }

    return Logger(label: "App")
}()
#elseif os(iOS)
var logger: Logger = {
    do {
        let logFileURL = Logger.appLogURL
        let fileLogger = try FileLogging(to: logFileURL)

        LoggingSystem.bootstrap { label in
            let fileLogHandler = FileLogHandler(label: label, fileLogger: fileLogger)
            var consoleLogHandler = StreamLogHandler.standardOutput(label: label)
            consoleLogHandler.logLevel = .debug
            let handlers: [LogHandler] = [
                fileLogHandler,
                consoleLogHandler
            ]

           return MultiplexLogHandler(handlers)
        }
    } catch {
        fatalError(error.localizedDescription)
    }

    return Logger(label: "App")
}()

#endif

extension Logger {

    func info(_ message: String) {
        let logger = Logger.Message(stringLiteral: "(\(Thread.current.hash)) \(message)")
        self.info(logger)

        // Add sentry breadcrumb
//        let crumb = Breadcrumb()
//        crumb.level = SentryLevel.info
//        crumb.message = message
//        SentrySDK.addBreadcrumb(crumb: crumb)
    }

    func debug(_ message: String) {
        let logger = Logger.Message(stringLiteral: "(\(Thread.current.hash)) \(message)")
        self.debug(logger)
    }

    func error(_ message: String) {
        let logger = Logger.Message(stringLiteral: "(\(Thread.current.hash)) \(message)")
        self.error(logger)
//        SentrySDK.capture(message: message)
    }
}
