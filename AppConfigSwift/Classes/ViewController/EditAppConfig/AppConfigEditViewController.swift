//
//  AppConfigEditViewController.swift
//  AppConfigSwift Pod
//
//  Library view controller: edit configuration
//  Change values of a new or existing configuration
//

import UIKit

public class AppConfigEditViewController : UIViewController, AppConfigEditTableDelegate {
    
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
    
    public override func viewDidLoad() {
        //Set title
        super.viewDidLoad()
        navigationItem.title = AppConfigBundle.localizedString(newConfig ? "CFLAC_EDIT_NEW_TITLE" : "CFLAC_EDIT_TITLE")
        navigationController?.navigationBar.translucent = false
        
        //Add button to close the configuration selection
        if navigationController != nil {
            //Obtain colors
            let tintColor = view.tintColor
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let highlightColor: UIColor = UIColor.init(red: red, green: green, blue: blue, alpha: 0.25)
            
            //Add cancel button
            let cancelButton: UIButton = UIButton()
            cancelButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            cancelButton.setTitle(AppConfigBundle.localizedString("CFLAC_SHARED_CANCEL"), forState: UIControlState.Normal)
            cancelButton.setTitleColor(tintColor, forState: UIControlState.Normal)
            cancelButton.setTitleColor(highlightColor, forState: UIControlState.Highlighted)
            let cancelButtonSize: CGSize = cancelButton.sizeThatFits(CGSizeZero)
            cancelButton.frame = CGRectMake(0, 0, cancelButtonSize.width, cancelButtonSize.height)
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
            
            //Wrap in bar button item
            let cancelButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: cancelButton)
            navigationItem.leftBarButtonItem = cancelButtonWrapper

            //Create button
            let saveButton: UIButton = UIButton()
            saveButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            saveButton.setTitle(AppConfigBundle.localizedString("CFLAC_SHARED_SAVE"), forState: UIControlState.Normal)
            saveButton.setTitleColor(tintColor, forState: UIControlState.Normal)
            saveButton.setTitleColor(highlightColor, forState: UIControlState.Highlighted)
            let saveButtonSize: CGSize = saveButton.sizeThatFits(CGSizeZero)
            saveButton.frame = CGRectMake(0, 0, saveButtonSize.width, saveButtonSize.height)
            saveButton.addTarget(self, action: #selector(saveButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
            
            //Wrap in bar button item
            let saveButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: saveButton)
            navigationItem.rightBarButtonItem = saveButtonWrapper
        }
        
        //Update configuration list
        AppConfigStorage.sharedManager.loadFromSource({
            self.editConfigTable.setConfigurationSettings(self.obtainSettings(), model: AppConfigStorage.sharedManager.configManager()?.obtainBaseModelInstance())
        })
    }
    
    public override func loadView() {
        editConfigTable.delegate = self
        view = editConfigTable
    }
    
    
    // --
    // MARK: Helpers
    // --
    
    func obtainSettings() -> [String: Any] {
        var settings = AppConfigStorage.sharedManager.configSettings(configName) ?? [:]
        if newConfig {
            settings["name"] = "\(configName) \(AppConfigBundle.localizedString("CFLAC_EDIT_COPY_SUFFIX"))"
        }
        return settings
    }
    

    // --
    // MARK: Selectors
    // --
    
    func cancelButtonPressed(sender: UIButton) {
        //TODO: are you sure dialog/check?
        cancelEditing()
    }
    
    func saveButtonPressed(sender: UIButton) {
        saveConfig(editConfigTable.obtainNewConfigurationSettings())
    }
    

    // --
    // MARK: CFLAppConfigEditTableDelegate
    // --
    
    func saveConfig(newSettings: [String: Any]) {
        let wasSelected = configName == AppConfigStorage.sharedManager.selectedConfig()
        if AppConfigStorage.sharedManager.isCustomConfig(configName) || AppConfigStorage.sharedManager.isConfigOverride(configName) {
            AppConfigStorage.sharedManager.removeConfig(configName)
        }
        var storeSettings = newSettings
        var newName = storeSettings["name"] as? String ?? ""
        if newName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count == 0 {
            newName = AppConfigBundle.localizedString("CFLAC_EDIT_COPY_NONAME")
            storeSettings["name"] = newName
        }
        AppConfigStorage.sharedManager.putCustomConfig(storeSettings, forConfig: newName)
        if wasSelected {
            AppConfigStorage.sharedManager.selectConfig(newName)
        }
        AppConfigStorage.sharedManager.synchronizeCustomConfigsWithUserDefaults()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func cancelEditing() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func revertConfig() {
        let wasSelected = configName == AppConfigStorage.sharedManager.selectedConfig()
        if AppConfigStorage.sharedManager.isCustomConfig(configName) || AppConfigStorage.sharedManager.isConfigOverride(configName) {
            AppConfigStorage.sharedManager.removeConfig(configName)
            AppConfigStorage.sharedManager.synchronizeCustomConfigsWithUserDefaults()
        }
        if wasSelected {
            AppConfigStorage.sharedManager.selectConfig(configName)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
}
