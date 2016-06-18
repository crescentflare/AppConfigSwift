//
//  ExampleAppConfigRunType.swift
//  AppConfigSwift Example
//
//  App config: application configuration run setting
//  An enum used by the application build configuration
//

import UIKit
import AppConfigSwift

//Enum definition using string raw values for storage
enum ExampleAppConfigRunType: String {
    
    case RunNormally = "runNormally"
    case RunQuickly = "runQuickly"
    case RunStrictly = "runStrictly"

}
