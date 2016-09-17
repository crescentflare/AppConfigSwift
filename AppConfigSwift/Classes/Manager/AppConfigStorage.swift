//
//  AppConfigStorage.swift
//  AppConfigSwift Pod
//
//  Library manager: storage class
//  Contains app config storage and provides the main interface
//

open class AppConfigStorage {

    // --
    // MARK: Notification center ID
    // --

    open static let configurationChanged = "AppConfigStorage.configurationChanged"
    

    // --
    // MARK: Singleton instance
    // --
    
    open static let sharedManager: AppConfigStorage = AppConfigStorage()
    

    // --
    // MARK: Userdefaults keys
    // --
    
    fileprivate static let defaultsSelectedConfigName = "AppConfig_SelectedConfigName"
    fileprivate static let defaultsSelectedConfigDictionary = "AppConfig_SelectedConfigDictionary"
    fileprivate static let defaultsCustomConfigs = "AppConfig_CustomConfigs"

    
    // --
    // MARK: Members
    // --

    var configManagerInstance: AppConfigBaseManager?
    var storedConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
    var customConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
    var loadFromAssetFile: String?
    var selectedItem: String?
    var customConfigLoaded: Bool = false
    var activated: Bool = false

    
    // --
    // MARK: Initialization
    // --
    
    //Initialization
    public init() { }
    
    //Activate storage, call this when using the selection menu
    //(optionally) specify the custom manager implementation to use
    open func activate(_ manager: AppConfigBaseManager? = nil) {
        configManagerInstance = manager
        loadSelectedItemFromUserDefaults()
        if selectedItem != nil && storedConfigs[selectedItem!] != nil {
            manager?.applyConfigToModel(storedConfigs[selectedItem!] as! [String: Any], name: selectedItem)
        }
        activated = true
    }

    //Determine if the storage has been activated
    //Useful to determine if the storage is being used or not to override the configuration (for test/production builds)
    open func isActivated() -> Bool {
        return activated
    }

    
    // --
    // MARK: Internal manager access
    // --

    //Obtain manager instance, only used internally if the given manager is a singleton (which is recommended)
    open func configManager() -> AppConfigBaseManager? {
        return configManagerInstance
    }
    
    
    // --
    // MARK: Obtain from storage
    // --
    
    //Return settings for the given configuration
    open func configSettings(_ config: String) -> [String: Any]? {
        if let customConfig = customConfigs[config] as? [String: Any] {
            return customConfig
        }
        return storedConfigs[config] as? [String: Any]
    }

    //Return the current selected configuration, or nil if none are selected
    open func selectedConfig() -> String? {
        return selectedItem
    }
    
    //Obtain a list of loaded configurations
    open func obtainConfigList() -> [String] {
        var list: [String] = []
        for key in storedConfigs.allKeys() {
            list.append(key)
        }
        return list
    }

    //Obtain a list of loaded custom configurations
    open func obtainCustomConfigList() -> [String] {
        var list: [String] = []
        for key in customConfigs.allKeys() {
            if !isConfigOverride(key) {
                list.append(key)
            }
        }
        return list
    }

    
    // --
    // MARK: Add to storage
    // --
    
    //Set custom values for an existing or new configuration
    open func putCustomConfig(_ settings: [String: Any], forConfig: String) {
        if customConfigs[forConfig] != nil {
            removeConfig(forConfig)
        }
        if storedConfigs[forConfig] == nil || !dictionariesEqual(storedConfigs[forConfig] as? [String: Any], rhs: settings) {
            customConfigs[forConfig] = settings
        }
    }

    fileprivate func dictionariesEqual(_ lhs: [String: Any]?, rhs: [String: Any]?) -> Bool {
        var tmpLhs: [String: AnyObject] = [:]
        var tmpRhs: [String: AnyObject] = [:]
        if lhs != nil {
            for (key, value) in lhs! {
                tmpLhs[key] = value as? AnyObject
            }
        }
        if rhs != nil {
            for (key, value) in rhs! {
                tmpRhs[key] = value as? AnyObject
            }
        }
        return NSDictionary(dictionary: tmpLhs).isEqual(to: tmpRhs)
    }

    
    // --
    // MARK: Other operations
    // --
    
    //Remove a configuration
    open func removeConfig(_ config: String) -> Bool {
        var removed = false
        if customConfigs[config] != nil {
            customConfigs[config] = nil
            removed = true
        } else if storedConfigs[config] != nil {
            storedConfigs[config] = nil
            removed = true
        }
        if removed && config == selectedItem {
            selectedItem = nil
            configManagerInstance?.applyConfigToModel([:], name: selectedItem)
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppConfigStorage.configurationChanged), object: self)
        }
        return removed
    }

    //Select a configuration
    open func selectConfig(_ configName: String?) {
        selectedItem = nil
        if configName != nil {
            for key in customConfigs.allKeys() {
                if key == configName! {
                    selectedItem = key
                    break
                }
            }
        }
        if selectedItem == nil && configName != nil {
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
                config = customConfigs[selectedItem!] as? [String: Any]
                if config == nil {
                    config = storedConfigs[selectedItem!] as? [String: Any]
                }
            }
            configManagerInstance?.applyConfigToModel(config ?? [:], name: selectedItem)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppConfigStorage.configurationChanged), object: self)
    }

    //Return if the given configuration is an extra custom configuration
    open func isCustomConfig(_ config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] == nil
    }
    
    //Return if the given configuration has settings being overridden
    open func isConfigOverride(_ config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] != nil
    }

    
    // --
    // MARK: Loading
    // --

    //Supply the path of the file containing the overrides
    //Should point to a plist file
    //The file is only loaded when the selection screen is opened
    open func setLoadingSourceAssetFile(_ filePath: String?) {
        loadFromAssetFile = filePath
    }
    
    //Load configurations, called internally by library view controllers
    open func loadFromSource(_ completion: @escaping () -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let loadedConfigs: AppConfigOrderedDictionary? = self.loadFromSourceInternal(self.loadFromAssetFile)
            DispatchQueue.main.async {
                if loadedConfigs != nil {
                    self.storedConfigs = loadedConfigs!
                    self.loadFromAssetFile = nil
                }
                if !self.customConfigLoaded {
                    self.loadCustomConfigurationsFromUserDefaults()
                    self.customConfigLoaded = true
                }
                completion()
            }
        }
    }
    
    //Load configurations, same as above but without threading
    open func loadFromSourceSync() {
        let loadedConfigs: AppConfigOrderedDictionary<String, Any>? = loadFromSourceInternal(loadFromAssetFile)
        if loadedConfigs != nil {
            storedConfigs = loadedConfigs!
            loadFromAssetFile = nil
        }
        if !customConfigLoaded {
            loadCustomConfigurationsFromUserDefaults()
            customConfigLoaded = true
        }
    }
    
    //Internal private method: load configurations from file
    fileprivate func loadFromSourceInternal(_ fileName: String?) -> AppConfigOrderedDictionary<String, Any>? {
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
                        let configName: String? = dictionary["name"] as? String
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
    fileprivate func addStorageItemFromDictionary(_ loadedConfigs: inout AppConfigOrderedDictionary<String, Any>, name: String, dictionary: [String: AnyObject], defaults:
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
                    let configName: String? = dictionary["name"] as? String
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
    
    open func synchronizeCustomConfigsWithUserDefaults() {
        var configs: [[String: AnyObject]] = []
        for key in customConfigs.allKeys() {
            if let customConfig = customConfigs[key] as? [String: Any] {
                var storeDictionary: [String: AnyObject] = [:]
                for (key, value) in customConfig {
                    storeDictionary[key] = value as? AnyObject
                }
                configs.append(storeDictionary)
            }
        }
        UserDefaults.standard.setValue(configs, forKey: AppConfigStorage.defaultsCustomConfigs)
    }

    fileprivate func loadSelectedItemFromUserDefaults() {
        selectedItem = UserDefaults.standard.value(forKey: AppConfigStorage.defaultsSelectedConfigName) as? String
        if selectedItem != nil {
            if let values = UserDefaults.standard.value(forKey: AppConfigStorage.defaultsSelectedConfigDictionary) as? [String: AnyObject] {
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
    
    fileprivate func storeSelectedItemInUserDefaults() {
        if let settings = customConfigs[selectedItem ?? ""] ?? storedConfigs[selectedItem ?? ""] {
            var storeDictionary: [String: AnyObject] = [:]
            for (key, value) in settings as! [String: Any] {
                storeDictionary[key] = value as? AnyObject
            }
            UserDefaults.standard.setValue(selectedItem, forKey: AppConfigStorage.defaultsSelectedConfigName)
            UserDefaults.standard.setValue(storeDictionary, forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        } else {
            UserDefaults.standard.removeObject(forKey: AppConfigStorage.defaultsSelectedConfigName)
            UserDefaults.standard.removeObject(forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        }
    }

    fileprivate func loadCustomConfigurationsFromUserDefaults() {
        customConfigs.removeAllObjects()
        if let configs = UserDefaults.standard.value(forKey: AppConfigStorage.defaultsCustomConfigs) as? [[String: AnyObject]] {
            for config in configs {
                var loadDictionary: [String: Any] = [:]
                for (key, value) in config {
                    loadDictionary[key] = value as Any
                }
                if let dictionaryName = loadDictionary["name"] as? String {
                    customConfigs[dictionaryName] = loadDictionary
                }
            }
        }
    }

    
    // --
    // MARK: Observers
    // --
    
    open func addDataObserver(_ observer: NSObject, selector: Selector, name: String) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: self)
    }
    
    open func removeDataObserver(_ observer: NSObject, name: String) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: name), object: self)
    }
    
}
