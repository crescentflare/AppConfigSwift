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
    public func activate(manager: AppConfigBaseManager? = nil) {
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
    
    //Return settings for the given configuration
    public func configSettings(config: String) -> [String: Any]? {
        if let customConfig = customConfigs[config] as? [String: Any] {
            return customConfig
        }
        return storedConfigs[config] as? [String: Any]
    }

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

    //Obtain a list of loaded custom configurations
    public func obtainCustomConfigList() -> [String] {
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
    public func putCustomConfig(settings: [String: Any], forConfig: String) {
        if customConfigs[forConfig] != nil {
            removeConfig(forConfig)
        }
        if storedConfigs[forConfig] == nil || !dictionariesEqual(storedConfigs[forConfig] as? [String: Any], rhs: settings) {
            customConfigs[forConfig] = settings
        }
    }

    private func dictionariesEqual(lhs: [String: Any]?, rhs: [String: Any]?) -> Bool {
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
        return NSDictionary(dictionary: tmpLhs).isEqualToDictionary(tmpRhs)
    }

    
    // --
    // MARK: Other operations
    // --
    
    //Remove a configuration
    public func removeConfig(config: String) -> Bool {
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
            NSNotificationCenter.defaultCenter().postNotificationName(AppConfigStorage.configurationChanged, object: self)
        }
        return removed
    }

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
                config = storedConfigs[selectedItem!] as? [String: Any]
            }
            configManagerInstance?.applyConfigToModel(config ?? [:], name: selectedItem)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(AppConfigStorage.configurationChanged, object: self)
    }

    //Return if the given configuration is an extra custom configuration
    public func isCustomConfig(config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] == nil
    }
    
    //Return if the given configuration has settings being overridden
    public func isConfigOverride(config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] != nil
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
            let loadedConfigs: AppConfigOrderedDictionary? = self.loadFromSourceInternal(self.loadFromAssetFile)
            dispatch_async(dispatch_get_main_queue()) {
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
    public func loadFromSourceSync() {
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
    
    public func synchronizeCustomConfigWithUserDefaults(config: String) {
        if customConfigs[config] != nil {
            storeCustomItemInUserDefaults(config)
        } else {
            removeCustomItemFromUserDefaults(config)
        }
    }

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
                storeDictionary[key] = value as? AnyObject
            }
            NSUserDefaults.standardUserDefaults().setValue(selectedItem, forKey: AppConfigStorage.defaultsSelectedConfigName)
            NSUserDefaults.standardUserDefaults().setValue(storeDictionary, forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(AppConfigStorage.defaultsSelectedConfigName)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(AppConfigStorage.defaultsSelectedConfigDictionary)
        }
    }

    private func storeCustomItemInUserDefaults(config: String) {
        if customConfigs[config] != nil {
            var configs: [[String: AnyObject]] = []
            removeCustomItemFromUserDefaults(config)
            if let customConfigs = NSUserDefaults.standardUserDefaults().valueForKey(AppConfigStorage.defaultsCustomConfigs) as? [[String: AnyObject]] {
                configs = customConfigs
            }
            if let customConfig = customConfigs[config] as? [String: Any] {
                var storeDictionary: [String: AnyObject] = [:]
                for (key, value) in customConfig as! [String: Any] {
                    storeDictionary[key] = value as? AnyObject
                }
                configs.append(storeDictionary)
            }
            NSUserDefaults.standardUserDefaults().setValue(configs, forKey: AppConfigStorage.defaultsCustomConfigs)
        }
    }
    
    private func removeCustomItemFromUserDefaults(config: String) {
        if var configs = NSUserDefaults.standardUserDefaults().valueForKey(AppConfigStorage.defaultsCustomConfigs) as? [[String: AnyObject]] {
            for i in 0..<configs.count {
                let settings = configs[i]
                if let name = settings["name"] as? String {
                    if name == config {
                        configs.removeAtIndex(i)
                        break
                    }
                }
            }
            NSUserDefaults.standardUserDefaults().setValue(configs, forKey: AppConfigStorage.defaultsCustomConfigs)
        }
    }
    
    private func loadCustomConfigurationsFromUserDefaults() {
        customConfigs.removeAllObjects()
        if var configs = NSUserDefaults.standardUserDefaults().valueForKey(AppConfigStorage.defaultsCustomConfigs) as? [[String: AnyObject]] {
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
    
    public func addDataObserver(observer: NSObject, selector: Selector, name: String) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: self)
    }
    
    public func removeDataObserver(observer: NSObject, name: String) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: self)
    }
    
}
