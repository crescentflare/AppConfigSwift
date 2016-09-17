//
//  AppConfigEditViewController.swift
//  AppConfigSwift Pod
//
//  Library view controller: edit configuration
//  Change values of a new or existing configuration
//

import UIKit

open class AppConfigEditViewController : UIViewController, AppConfigEditTableDelegate {
    
    // --
    // MARK: Members
    // --
    
    var newConfig = false
    var configName = ""
    let editConfigTable: AppConfigEditTable = AppConfigEditTable()

    
    // --
    // MARK: Lifecycle
    // --
    
    init(configName: String, newConfig: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.newConfig = newConfig
        self.configName = configName
        editConfigTable.newConfig = newConfig
        editConfigTable.configName = configName
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        //Set title
        super.viewDidLoad()
        navigationItem.title = AppConfigBundle.localizedString(key: newConfig ? "CFLAC_EDIT_NEW_TITLE" : "CFLAC_EDIT_TITLE")
        navigationController?.navigationBar.isTranslucent = false
        
        //Add button to close the configuration selection
        if navigationController != nil {
            //Obtain colors
            let tintColor = view.tintColor
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            tintColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let highlightColor: UIColor = UIColor.init(red: red, green: green, blue: blue, alpha: 0.25)
            
            //Add cancel button
            let cancelButton: UIButton = UIButton()
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            cancelButton.setTitle(AppConfigBundle.localizedString(key: "CFLAC_SHARED_CANCEL"), for: UIControlState())
            cancelButton.setTitleColor(tintColor, for: UIControlState())
            cancelButton.setTitleColor(highlightColor, for: UIControlState.highlighted)
            let cancelButtonSize: CGSize = cancelButton.sizeThatFits(CGSize.zero)
            cancelButton.frame = CGRect(x: 0, y: 0, width: cancelButtonSize.width, height: cancelButtonSize.height)
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControlEvents.touchUpInside)
            
            //Wrap in bar button item
            let cancelButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: cancelButton)
            navigationItem.leftBarButtonItem = cancelButtonWrapper

            //Create button
            let saveButton: UIButton = UIButton()
            saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            saveButton.setTitle(AppConfigBundle.localizedString(key: "CFLAC_SHARED_SAVE"), for: UIControlState())
            saveButton.setTitleColor(tintColor, for: UIControlState())
            saveButton.setTitleColor(highlightColor, for: UIControlState.highlighted)
            let saveButtonSize: CGSize = saveButton.sizeThatFits(CGSize.zero)
            saveButton.frame = CGRect(x: 0, y: 0, width: saveButtonSize.width, height: saveButtonSize.height)
            saveButton.addTarget(self, action: #selector(saveButtonPressed), for: UIControlEvents.touchUpInside)
            
            //Wrap in bar button item
            let saveButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: saveButton)
            navigationItem.rightBarButtonItem = saveButtonWrapper
        }
        
        //Update configuration list
        AppConfigStorage.shared.loadFromSource(completion: {
            self.editConfigTable.setConfigurationSettings(self.obtainSettings(), model: AppConfigStorage.shared.configManager()?.obtainBaseModelInstance())
        })
    }
    
    open override func loadView() {
        editConfigTable.delegate = self
        view = editConfigTable
    }
    
    
    // --
    // MARK: Helpers
    // --
    
    func obtainSettings() -> [String: Any] {
        var settings = AppConfigStorage.shared.configSettings(config: configName) ?? [:]
        if newConfig {
            settings["name"] = "\(configName) \(AppConfigBundle.localizedString(key: "CFLAC_EDIT_COPY_SUFFIX"))"
        }
        return settings
    }
    

    // --
    // MARK: Selectors
    // --
    
    func cancelButtonPressed(_ sender: UIButton) {
        //TODO: are you sure dialog/check?
        cancelEditing()
    }
    
    func saveButtonPressed(_ sender: UIButton) {
        saveConfig(editConfigTable.obtainNewConfigurationSettings())
    }
    

    // --
    // MARK: CFLAppConfigEditTableDelegate
    // --
    
    func saveConfig(_ newSettings: [String: Any]) {
        let wasSelected = configName == AppConfigStorage.shared.selectedConfig()
        if AppConfigStorage.shared.isCustomConfig(config: configName) || AppConfigStorage.shared.isConfigOverride(config: configName) {
            AppConfigStorage.shared.removeConfig(config: configName)
        }
        var storeSettings = newSettings
        var newName = storeSettings["name"] as? String ?? ""
        if newName.trimmingCharacters(in: CharacterSet.whitespaces).characters.count == 0 {
            newName = AppConfigBundle.localizedString(key: "CFLAC_EDIT_COPY_NONAME")
            storeSettings["name"] = newName
        }
        AppConfigStorage.shared.putCustomConfig(settings: storeSettings, forConfig: newName)
        if wasSelected {
            AppConfigStorage.shared.selectConfig(configName: newName)
        }
        AppConfigStorage.shared.synchronizeCustomConfigsWithUserDefaults()
        navigationController?.popViewController(animated: true)
    }
    
    func cancelEditing() {
        navigationController?.popViewController(animated: true)
    }
    
    func revertConfig() {
        let wasSelected = configName == AppConfigStorage.shared.selectedConfig()
        if AppConfigStorage.shared.isCustomConfig(config: configName) || AppConfigStorage.shared.isConfigOverride(config: configName) {
            AppConfigStorage.shared.removeConfig(config: configName)
            AppConfigStorage.shared.synchronizeCustomConfigsWithUserDefaults()
        }
        if wasSelected {
            AppConfigStorage.shared.selectConfig(configName: configName)
        }
        navigationController?.popViewController(animated: true)
    }
    
}
