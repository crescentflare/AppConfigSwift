//
//  Logger.swift
//  AppConfigSwift
//
//  A quickly written (unoptimized) utility to log to the system and to a file
//  Uses the global setting to determine if the log should be written
//  Used by the log plugin to show the log from the selection menu
//

import UIKit
import AppConfigSwift

class Logger {

    // --
    // MARK: Constants
    // --
    
    private static let logFilename = "app_log.txt"

    
    // --
    // MARK: Members
    // --
    
    private static var logFileString: String?
    

    // --
    // MARK: Logging methods
    // --

    static func log(text: String) {
        if ExampleAppConfigManager.currentConfig().logLevel != .logDisabled {
            logOutput(text: text)
        }
    }
    
    static func logVerbose(text: String) {
        if ExampleAppConfigManager.currentConfig().logLevel == .logVerbose {
            logOutput(text: text)
        }
    }
    
    static private func logOutput(text: String) {
        print(text)
        printToFile(text: text)
    }


    // --
    // MARK: File access
    // --
    
    static func clear() {
        do {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(logFilename)
                try "".write(to: fileURL, atomically: false, encoding: .utf8)
                logFileString = ""
            }
        } catch {
            // Ignored
        }
    }
    
    static func printToFile(text: String) {
        readLogIfNeeded()
        if logFileString!.count > 0 {
            logFileString = logFileString! + "\n" + text
        } else {
            logFileString = text
        }
        do {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(logFilename)
                try logFileString!.write(to: fileURL, atomically: false, encoding: .utf8)
            }
        } catch {
            // Ignore
        }
    }
    
    static func logString() -> String {
        readLogIfNeeded()
        return logFileString!
    }
    
    static private func readLogIfNeeded() {
        if logFileString == nil {
            do {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentDirectory.appendingPathComponent(logFilename)
                    logFileString = try String(contentsOf: fileURL)
                }
            } catch {
                logFileString = ""
            }
        }
    }

}
