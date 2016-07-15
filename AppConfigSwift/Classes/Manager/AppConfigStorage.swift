//
//  AppConfigStorage.swift
//  AppConfigSwift Pod
//
//  Library manager: storage class
//  Contains app config storage and provides the main interface
//

public class AppConfigStorage {

    // --
    // MARK: Notification center ID
    // --

    public static let configurationChanged = "AppConfigStorage.configurationChanged"
    

    // --
    // MARK: Singleton instance
    // --
    
    public static let sharedManager: AppConfigStorage = AppConfigStorage()
    

    // --
    // MARK: Userdefaults keys
    // --
    
    private static let defaultsSelectedConfigName = "AppConfig_SelectedConfigName"
    private static let defaultsSelectedConfigDictionary = "AppConfig_SelectedConfigDictionary"
    private static let defaultsCustomConfigs = "AppConfig_CustomConfigs"

    
    // --
    // MARK: Members
    // --

    var configManagerInstance: AppConfigBaseManager?
    var storedConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
    var loadFromAssetFile: String?
    var selectedItem: String?
    var activated: Bool = false

    
    // --
    // MARK: Initialization
    // --
    
    //Initialization
    public init() { }
    
    //Activate storage, call this when using the selection menu
    //(optionally) specify the custom manager implementation to use
    public func activate() {
        self.activate(nil)
    }

    public func activate(manager: AppConfigBaseManager?) {
        configManagerInstance = manager
        loadSelectedItemFromUserDefaults()
        if selectedItem != nil && storedConfigs[selectedItem!] != nil {
            manager?.applyConfigToModel(storedConfigs[selectedItem!] as! [String: Any], name: selectedItem)
        }
        activated = true
    }

    //Determine if the storage has been activated
    //Useful to determine if the storage is being used or not to override the configuration (for test/production builds)
    public func isActivated() -> Bool {
        return activated
    }

    
    // --
    // MARK: Internal manager access
    // --

    //Obtain manager instance, only used internally if the given manager is a singleton (which is recommended)
    public func configManager() -> AppConfigBaseManager? {
        return configManagerInstance
    }
    
    
    // --
    // MARK: Obtain from storage
    // --
    
    //Return the current selected configuration, or nil if none are selected
    public func selectedConfig() -> String? {
        return selectedItem
    }
    
    //Obtain a list of loaded configurations
    public func obtainConfigList() -> [String] {
        var list: [String] = []
        for key in storedConfigs.allKeys() {
            list.append(key)
        }
        return list
    }

    
    // --
    // MARK: Other operations
    // --
    
    //Select a configuration
    public func selectConfig(configName: String?) {
        selectedItem = nil
        if configName != nil {
            for key in storedConfigs.allKeys() {
                if key == configName! {
                    selectedItem = key
                    break
                }
            }
        }
        storeSelectedItemInUserDefaults()
        if configManagerInstance != nil {
            var config: [String: Any]? = nil
            if selectedItem != nil {
                config = storedConfigs[selectedItem!] as! [String: Any]
            }
            configManagerInstance?.applyConfigToModel(config ?? [:], name: selectedItem)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(AppConfigStorage.configurationChanged, object: self)
    }
    
    
    // --
    // MARK: Loading
    // --

    //Supply the path of the file containing the overrides
    //Should point to a plist file
    //The file is only loaded when the selection screen is opened
    public func setLoadingSourceAssetFile(filePath: String?) {
        loadFromAssetFile = filePath
    }
    
    //Load configurations, called internally by library view controllers
    public func loadFromSource(completion: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var loadedConfigs: AppConfigOrderedDictionary? = self.loadFromSourceInternal(self.loadFromAssetFile)
            dispatch_async(dispatch_get_main_queue()) {
                if loadedConfigs != nil {
                    self.storedConfigs = loadedConfigs!
                    self.loadFromAssetFile = nil
                }
                completion()
            }
        }
    }
    
    //Load configurations, same as above but without threading
    public func loadFromSourceSync() {
        var loadedConfigs: AppConfigOrderedDictionary<String, Any>? = loadFromSourceInternal(loadFromAssetFile)
        if loadedConfigs != nil {
            storedConfigs = loadedConfigs!
            loadFromAssetFile = nil
        }
    }
    
    //Internal private method: load configurations from file
    private func loadFromSourceInternal(fileName: String?) -> AppConfigOrderedDictionary<String, Any>? {
        if fileName != nil {
            let loadedArray: NSMutableArray? = NSMutableArray(contentsOfFile: fileName!)
            if loadedArray != nil && loadedArray!.count > 0 {
                //Obtain default item with values from manager model (if applicable)
                var defaultItem: [String: Any]? = nil
                defaultItem = configManagerInstance?.obtainBaseModelInstance().obtainValues()

                //Add items (can be recursive for sub configs)
                let loadedItems = loadedArray! as [AnyObject]
                var loadedConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
                for value in loadedItems {
                    if let dictionary = value as? [String: AnyObject] {
                        let configName: String? = dictionary["name"] as! String
                        if configName != nil {
                            addStorageItemFromDictionary(&loadedConfigs, name: configName!, dictionary: dictionary, defaults: defaultItem)
                        }
                    }
                }
                return loadedConfigs
            }
        }
        return nil
    }
    
    //Internal private method: add a single configuration from a dictionary, can be recursive when having sub configs
    private func addStorageItemFromDictionary(inout loadedConfigs: AppConfigOrderedDictionary<String, Any>, name: String, dictionary: [String: AnyObject], defaults:
        [String: Any]?) {
        //Insert values
        var addItem: [String: Any] = defaults ?? [:]
        for (key, value) in dictionary {
            if key != "subConfigs" {
                addItem[key] = value
            }
        }
        loadedConfigs[name] = addItem
        
        //Search for sub configs
        if let subConfigs = dictionary["subConfigs"] as? [AnyObject] {
            for value in subConfigs {
                if let dictionary = value as? [String: AnyObject] {
                    let configName: String? = dictionary["name"] as! String
                    if configName != nil {
                        addStorageItemFromDictionary(&loadedConfigs, name: configName!, dictionary: dictionary, defaults: addItem)
                    }
                }
            }
        }
    }
    

    // --
    // MARK: Userdefaults handling
    // --
    
    private func loadSelectedItemFromUserDefaults() {
        selectedItem = NSUserDefaults.standardUserDefaults().valueForKey(AppConfigStorage.defaultsSelectedConfigName) as? String
        if selectedItem != nil {
            if let values = NSUserDefaults.standardUserDefaults().valueForKey(AppConfigStorage.defaultsSelectedConfigDictionary) as? [String: AnyObject] {
                var loadDictionary: [String: Any] = [:]
                for (key, value) in values {
                    loadDictionary[key] = value as Any
                }
                storedConfigs[selectedItem!] = loadDictionary
            } else {
                selectedItem = nil
            }
        }
    }
    
    private func storeSelectedItemInUserDefaults() {
        if selectedItem != nil && storedConfigs[selectedItem!] != nil {
            var storeDictionary: [String: AnyObject] = [:]
            for (key, value) in storedConfigs[selectedItem!] as! [String: Any] {
                storeDictionary[key] = value as! AnyObject
            }
            NSUserDefaults.standardUserDefaults().setValue(selectedItem, forKey: AppConfigStorage.defaultsSelectedConfigName)
            NSUserDefaults.standardUserDefaults().setValue(storeDictionary, forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(AppConfigStorage.defaultsSelectedConfigName)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(AppConfigStorage.defaultsSelectedConfigDictionary)
        }
    }

    
    // --
    // MARK: Observers
    // --
    
    public func addDataObserver(observer: NSObject, selector: Selector, name: String) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: self)
    }
    
    public func removeDataObserver(observer: NSObject, name: String) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: self)
    }
    
}
