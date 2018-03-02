//
//  ViewController.swift
//  AppConfigSwift Example
//
//  A simple screen which launches the app config selection screen
//  It will show the selected values on-screen
//

import UIKit
import AppConfigSwift

class ViewController: UIViewController {

    // --
    // MARK: View components
    // --
    
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var selectedConfigValue: UILabel!
    @IBOutlet var apiUrlValue: UILabel!
    @IBOutlet var runTypeValue: UILabel!
    @IBOutlet var acceptAllSslValue: UILabel!
    @IBOutlet var networkTimeoutValue: UILabel!
    @IBOutlet var consoleUrlValue: UILabel!
    @IBOutlet var consoleTimeoutValue: UILabel!
    @IBOutlet var enableConsoleValue: UILabel!
    @IBOutlet var logLevelValue: UILabel!

    
    // --
    // MARK: Lifecycle
    // --
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateConfigurationValues()
        AppConfigStorage.shared.addDataObserver(self, selector: #selector(configurationDidUpdate), name: AppConfigStorage.configurationChanged)
        if !AppConfigStorage.shared.isActivated() {
            changeButton.isHidden = true
        }
    }
    
    deinit {
        AppConfigStorage.shared.removeDataObserver(self, name: AppConfigStorage.configurationChanged)
    }


    // --
    // MARK: Helper
    // --

    @objc func configurationDidUpdate() {
        Logger.log(text: "Configuration changed")
        updateConfigurationValues()
    }
    
    func updateConfigurationValues() {
        // Log settings
        Logger.logVerbose(text: "apiUrl set to: " + ExampleAppConfigManager.currentConfig().apiUrl)
        Logger.logVerbose(text: "runType set to: " + ExampleAppConfigManager.currentConfig().runType.rawValue)
        Logger.logVerbose(text: "acceptAllSsl set to: " + (ExampleAppConfigManager.currentConfig().acceptAllSSL ? "true" : "false"))
        Logger.logVerbose(text: "networkTimeout set to: " + String(ExampleAppConfigManager.currentConfig().networkTimeoutSec))

        // Update UI
        self.selectedConfigValue.text = ExampleAppConfigManager.currentConfig().name
        self.apiUrlValue.text = ExampleAppConfigManager.currentConfig().apiUrl
        self.runTypeValue.text = ExampleAppConfigManager.currentConfig().runType.rawValue
        self.acceptAllSslValue.text = ExampleAppConfigManager.currentConfig().acceptAllSSL ? "true" : "false"
        self.networkTimeoutValue.text = String(ExampleAppConfigManager.currentConfig().networkTimeoutSec)
        self.consoleUrlValue.text = ExampleAppConfigManager.currentConfig().consoleUrl
        self.consoleTimeoutValue.text = String(ExampleAppConfigManager.currentConfig().consoleTimeoutSec)
        self.enableConsoleValue.text = ExampleAppConfigManager.currentConfig().consoleEnabled ? "true" : "false"
        self.logLevelValue.text = ExampleAppConfigManager.currentConfig().logLevel.rawValue
    }
    
    
    // --
    // MARK: Selector
    // --
    
    @IBAction func changeConfiguration() {
        AppConfigManageViewController.launch()
    }
    
}
