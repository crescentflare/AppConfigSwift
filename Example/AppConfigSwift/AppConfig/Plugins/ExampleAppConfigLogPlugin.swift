//
//  ExampleAppConfigLogPlugin.swift
//  AppConfigSwift Example
//
//  App config: custom plugin for logging
//  This plugin is used to display the log when clicking on it from the app config menu
//

import UIKit
import AppConfigSwift

class ExampleAppConfigLogPlugin : AppConfigPlugin {
    
    // --
    // MARK: Implementation
    // --
    
    func displayName() -> String {
        return "View log"
    }
    
    func displayValue() -> String? {
        let logString = Logger.logString()
        let logLines = logString.split(separator: "\n")
        return "\(logLines.count) lines"
    }
    
    func interact(fromViewController: UIViewController) {
        fromViewController.navigationController?.pushViewController(ShowLogViewController(), animated: true)
    }
    
}
