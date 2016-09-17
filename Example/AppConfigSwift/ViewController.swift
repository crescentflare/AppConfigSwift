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
    
    
    // --
    // MARK: Lifecycle
    // --
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateConfigurationValues()
        AppConfigStorage.sharedManager.addDataObserver(self, selector: #selector(updateConfigurationValues), name: AppConfigStorage.configurationChanged)
        if !AppConfigStorage.sharedManager.isActivated() {
            changeButton.isHidden = true
        }
    }
    
    deinit {
        AppConfigStorage.sharedManager.removeDataObserver(self, name: AppConfigStorage.configurationChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // --
    // MARK: Helper
    // --

    func updateConfigurationValues() {
        self.selectedConfigValue.text = ExampleAppConfigManager.currentConfig().name
        self.apiUrlValue.text = ExampleAppConfigManager.currentConfig().apiUrl
        self.runTypeValue.text = ExampleAppConfigManager.currentConfig().runType.rawValue
        self.acceptAllSslValue.text = ExampleAppConfigManager.currentConfig().acceptAllSSL ? "true" : "false"
        self.networkTimeoutValue.text = String(ExampleAppConfigManager.currentConfig().networkTimeoutSec)
    }
    
    
    // --
    // MARK: Selector
    // --
    
    @IBAction func changeConfiguration() {
        let viewController: AppConfigManageViewController = AppConfigManageViewController()
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
}
