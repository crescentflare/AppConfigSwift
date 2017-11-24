//
//  ExampleAppConfigLogLevel.swift
//  AppConfigSwift Example
//
//  App config: application configuration log level
//  An enum used by the application build configuration
//

import UIKit
import AppConfigSwift

// Enum definition using string raw values for storage
enum ExampleAppConfigLogLevel: String {
    
    case logDisabled = "logDisabled"
    case logNormal = "logNormal"
    case logVerbose = "logVerbose"
    
    static func allValues() -> [ExampleAppConfigLogLevel] {
        return [logDisabled, logNormal, logVerbose]
    }

}
