//
//  AppConfigManageViewController.swift
//  AppConfigSwift Pod
//
//  Library view controller: edit configuration
//  Be able to select, add and edit app configurations
//

import UIKit

public class AppConfigManageViewController : UIViewController, AppConfigManageTableDelegate {
    
    // --
    // MARK: Members
    // --
    
    static var isOpenCounter = 0
    var isPresentedController = false
    var isLoaded = false
    var manageConfigTable = AppConfigManageTable()

    
    // --
    // MARK: Launching
    // --
    
    public static func launchFromShake() {
        if AppConfigManageViewController.isOpenCounter == 0 {
            let viewController = AppConfigManageViewController()
            let navigationController = UINavigationController.init(rootViewController: viewController)
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }

    
    // --
    // MARK: Lifecycle
    // --
    
    public override func viewDidLoad() {
        // Set title
        super.viewDidLoad()
        navigationItem.title = AppConfigBundle.localizedString(key: "CFLAC_MANAGE_TITLE")
        navigationController?.navigationBar.isTranslucent = false
        
        // Add button to close the configuration selection
        if navigationController != nil {
            // Obtain colors
            let tintColor = view.tintColor
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            tintColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let highlightColor = UIColor.init(red: red, green: green, blue: blue, alpha: 0.25)
            
            // Create button
            let doneButton = UIButton()
            doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            doneButton.setTitle(AppConfigBundle.localizedString(key: "CFLAC_SHARED_DONE"), for: UIControlState())
            doneButton.setTitleColor(tintColor, for: UIControlState())
            doneButton.setTitleColor(highlightColor, for: UIControlState.highlighted)
            let size = doneButton.sizeThatFits(CGSize.zero)
            doneButton.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            doneButton.addTarget(self, action: #selector(doneButtonPressed), for: UIControlEvents.touchUpInside)
            
            // Wrap in bar button item
            let doneButtonWrapper = UIBarButtonItem.init(customView: doneButton)
            navigationItem.leftBarButtonItem = doneButtonWrapper
        }
        
        // Update configuration list
        AppConfigStorage.shared.loadFromSource(completion: {
            self.isLoaded = true
            self.manageConfigTable.setConfigurations(AppConfigStorage.shared.obtainConfigList(), customConfigurations: AppConfigStorage.shared.obtainCustomConfigList(), lastSelected: AppConfigStorage.shared.selectedConfig())
        })
    }
    
    public override func loadView() {
        if navigationController != nil {
            isPresentedController = navigationController!.isBeingPresented
        } else {
            isPresentedController = isBeingPresented
        }
        manageConfigTable.delegate = self
        view = manageConfigTable
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if isLoaded {
            self.manageConfigTable.setConfigurations(AppConfigStorage.shared.obtainConfigList(), customConfigurations: AppConfigStorage.shared.obtainCustomConfigList(), lastSelected: AppConfigStorage.shared.selectedConfig())
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        AppConfigManageViewController.isOpenCounter += 1
    }
    
    deinit {
        if AppConfigManageViewController.isOpenCounter > 0 {
            AppConfigManageViewController.isOpenCounter -= 1
        }
    }
    
    
    // --
    // MARK: Selectors
    // --
    
    func doneButtonPressed(_ sender: UIButton) {
        if isPresentedController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    

    // --
    // MARK: AppConfigManageTableDelegate
    // --
    
    func selectedConfig(configName: String) {
        AppConfigStorage.shared.selectConfig(configName: configName)
        if isLoaded {
            self.manageConfigTable.setConfigurations(AppConfigStorage.shared.obtainConfigList(), customConfigurations: AppConfigStorage.shared.obtainCustomConfigList(), lastSelected: AppConfigStorage.shared.selectedConfig())
        }
    }
    
    func editConfig(configName: String) {
        let viewController = AppConfigEditViewController(configName: configName, newConfig: false)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func newCustomConfigFrom(configName: String) {
        let viewController = AppConfigEditViewController(configName: configName, newConfig: true)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
