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
    
    public static let shared = AppConfigStorage()
    

    // --
    // MARK: Userdefaults keys
    // --
    
    private static let defaultsSelectedConfigName = "AppConfig_SelectedConfigName"
    private static let defaultsSelectedConfigDictionary = "AppConfig_SelectedConfigDictionary"
    private static let defaultsCustomConfigs = "AppConfig_CustomConfigs"
    private static let defaultsGlobalConfig = "AppConfig_GlobalConfig"

    
    // --
    // MARK: Members
    // --

    var configManagerInstance: AppConfigBaseManager?
    var storedConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
    var customConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
    var globalConfig: [String: Any] = [:]
    var loadFromAssetFile: String?
    var selectedItem: String?
    var customConfigLoaded = false
    var activated = false

    
    // --
    // MARK: Initialization
    // --
    
    // Initialization
    public init() { }
    
    // Activate storage, call this when using the selection menu
    // (optionally) specify the custom manager implementation to use
    public func activate(manager: AppConfigBaseManager? = nil) {
        configManagerInstance = manager
        loadSelectedItemFromUserDefaults()
        loadGlobalConfigFromUserDefaults()
        if selectedItem != nil && storedConfigs[selectedItem!] != nil {
            manager?.applyConfigToModel(config: storedConfigs[selectedItem!] as! [String: Any], globalConfig: globalConfig, name: selectedItem)
        } else {
            manager?.applyConfigToModel(config: [:], globalConfig: globalConfig, name: nil)
        }
        activated = true
    }

    // Determine if the storage has been activated
    // Useful to determine if the storage is being used or not to override the configuration (for test/production builds)
    public func isActivated() -> Bool {
        return activated
    }

    
    // --
    // MARK: Internal manager access
    // --

    // Obtain manager instance, only used internally if the given manager is a singleton (which is recommended)
    public func configManager() -> AppConfigBaseManager? {
        return configManagerInstance
    }
    
    
    // --
    // MARK: Obtain from storage
    // --
    
    // Return settings for the given configuration
    public func configSettings(config: String) -> [String: Any]? {
        if let customConfig = customConfigs[config] as? [String: Any] {
            return customConfig
        }
        return storedConfigs[config] as? [String: Any]
    }
    
    // Return global settings
    public func obtainGlobalConfig() -> [String: Any] {
        return globalConfig
    }

    // Return the current selected configuration, or nil if none are selected
    public func selectedConfig() -> String? {
        return selectedItem
    }
    
    // Obtain a list of loaded configurations
    public func obtainConfigList() -> [String] {
        var list: [String] = []
        for key in storedConfigs.allKeys() {
            list.append(key)
        }
        return list
    }

    // Obtain a list of loaded custom configurations
    public func obtainCustomConfigList() -> [String] {
        var list: [String] = []
        for key in customConfigs.allKeys() {
            if !isConfigOverride(config: key) {
                list.append(key)
            }
        }
        return list
    }

    
    // --
    // MARK: Add to storage
    // --
    
    // Set custom values for an existing or new configuration
    public func putCustomConfig(settings: [String: Any], forConfig: String) {
        if customConfigs[forConfig] != nil {
            removeConfig(config: forConfig)
        }
        if storedConfigs[forConfig] == nil || !dictionariesEqual(storedConfigs[forConfig] as? [String: Any], settings) {
            customConfigs[forConfig] = settings
        }
    }

    private func dictionariesEqual(_ lhs: [String: Any]?, _ rhs: [String: Any]?) -> Bool {
        var tmpLhs: [String: AnyObject] = [:]
        var tmpRhs: [String: AnyObject] = [:]
        if lhs != nil {
            for (key, value) in lhs! {
                tmpLhs[key] = value as AnyObject
            }
        }
        if rhs != nil {
            for (key, value) in rhs! {
                tmpRhs[key] = value as AnyObject
            }
        }
        return NSDictionary(dictionary: tmpLhs).isEqual(to: tmpRhs)
    }

    
    // --
    // MARK: Other operations
    // --
    
    // Remove a configuration
    @discardableResult
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
            configManagerInstance?.applyConfigToModel(config: [:], globalConfig: globalConfig, name: selectedItem)
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppConfigStorage.configurationChanged), object: self)
        }
        return removed
    }

    // Select a configuration
    public func selectConfig(configName: String?) {
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
            configManagerInstance?.applyConfigToModel(config: config ?? [:], globalConfig: globalConfig, name: selectedItem)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppConfigStorage.configurationChanged), object: self)
    }
    
    // Update global config settings
    public func updateGlobalConfig(settings: [String: Any]) {
        if settings.count > 0 || globalConfig.count > 0 {
            globalConfig = settings
            storeGlobalConfigInUserDefaults()
            configManagerInstance?.applyConfigToModel(config: configSettings(config: selectedItem ?? "") ?? [:], globalConfig: globalConfig, name: selectedItem)
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppConfigStorage.configurationChanged), object: self)
        }
    }

    // Return if the given configuration is an extra custom configuration
    public func isCustomConfig(config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] == nil
    }
    
    // Return if the given configuration has settings being overridden
    public func isConfigOverride(config: String) -> Bool {
        return customConfigs[config] != nil && storedConfigs[config] != nil
    }

    
    // --
    // MARK: Loading
    // --

    // Supply the path of the file containing the overrides
    // Should point to a plist file
    // The file is only loaded when the selection screen is opened
    public func setLoadingSourceAsset(filePath: String?) {
        loadFromAssetFile = filePath
    }
    
    // Load configurations, called internally by library view controllers
    public func loadFromSource(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let loadedConfigs: AppConfigOrderedDictionary? = self.loadFromSourceInternal(fileName: self.loadFromAssetFile)
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
    
    // Load configurations, same as above but without threading
    public func loadFromSourceSync() {
        let loadedConfigs: AppConfigOrderedDictionary<String, Any>? = loadFromSourceInternal(fileName: loadFromAssetFile)
        if loadedConfigs != nil {
            storedConfigs = loadedConfigs!
            loadFromAssetFile = nil
        }
        if !customConfigLoaded {
            loadCustomConfigurationsFromUserDefaults()
            customConfigLoaded = true
        }
    }
    
    // Internal private method: load configurations from file
    private func loadFromSourceInternal(fileName: String?) -> AppConfigOrderedDictionary<String, Any>? {
        if fileName != nil {
            let loadedArray: NSMutableArray? = NSMutableArray(contentsOfFile: fileName!)
            if loadedArray != nil && loadedArray!.count > 0 {
                // Obtain default item with values from manager model (if applicable)
                var defaultItem: [String: Any]? = nil
                defaultItem = configManagerInstance?.obtainBaseModelInstance().obtainConfigurationValues()

                // Add items (can be recursive for sub configs)
                let loadedItems = loadedArray! as [AnyObject]
                var loadedConfigs: AppConfigOrderedDictionary<String, Any> = AppConfigOrderedDictionary()
                for value in loadedItems {
                    if let dictionary = value as? [String: AnyObject] {
                        let configName = dictionary["name"] as? String
                        if configName != nil {
                            addStorageItemFromDictionary(loadedConfigs: &loadedConfigs, name: configName!, dictionary: dictionary, defaults: defaultItem)
                        }
                    }
                }
                return loadedConfigs
            }
        }
        return nil
    }
    
    // Internal private method: add a single configuration from a dictionary, can be recursive when having sub configs
    private func addStorageItemFromDictionary(loadedConfigs: inout AppConfigOrderedDictionary<String, Any>, name: String, dictionary: [String: AnyObject], defaults:
        [String: Any]?) {
        // Insert values
        var addItem = defaults ?? [:]
        for (key, value) in dictionary {
            if key != "subConfigs" {
                addItem[key] = value
            }
        }
        loadedConfigs[name] = addItem
        
        // Search for sub configs
        if let subConfigs = dictionary["subConfigs"] as? [AnyObject] {
            for value in subConfigs {
                if let dictionary = value as? [String: AnyObject] {
                    let configName = dictionary["name"] as? String
                    if configName != nil {
                        addStorageItemFromDictionary(loadedConfigs: &loadedConfigs, name: configName!, dictionary: dictionary, defaults: addItem)
                    }
                }
            }
        }
    }
    

    // --
    // MARK: Userdefaults handling
    // --
    
    public func synchronizeCustomConfigsWithUserDefaults() {
        var configs: [[String: AnyObject]] = []
        for key in customConfigs.allKeys() {
            if let customConfig = customConfigs[key] as? [String: Any] {
                var storeDictionary: [String: AnyObject] = [:]
                for (key, value) in customConfig {
                    storeDictionary[key] = value as AnyObject
                }
                configs.append(storeDictionary)
            }
        }
        UserDefaults.standard.setValue(configs, forKey: AppConfigStorage.defaultsCustomConfigs)
    }

    private func loadSelectedItemFromUserDefaults() {
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
    
    private func storeSelectedItemInUserDefaults() {
        if let settings = customConfigs[selectedItem ?? ""] ?? storedConfigs[selectedItem ?? ""] {
            var storeDictionary: [String: AnyObject] = [:]
            for (key, value) in settings as! [String: Any] {
                storeDictionary[key] = value as AnyObject
            }
            UserDefaults.standard.setValue(selectedItem, forKey: AppConfigStorage.defaultsSelectedConfigName)
            UserDefaults.standard.setValue(storeDictionary, forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        } else {
            UserDefaults.standard.removeObject(forKey: AppConfigStorage.defaultsSelectedConfigName)
            UserDefaults.standard.removeObject(forKey: AppConfigStorage.defaultsSelectedConfigDictionary)
        }
    }

    private func loadCustomConfigurationsFromUserDefaults() {
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

    private func loadGlobalConfigFromUserDefaults() {
        if let values = UserDefaults.standard.value(forKey: AppConfigStorage.defaultsGlobalConfig) as? [String: AnyObject] {
            var loadDictionary: [String: Any] = [:]
            for (key, value) in values {
                loadDictionary[key] = value as Any
            }
            globalConfig = loadDictionary
        } else {
            globalConfig = [:]
        }
    }
    
    private func storeGlobalConfigInUserDefaults() {
        var storeDictionary: [String: AnyObject] = [:]
        for (key, value) in globalConfig {
            storeDictionary[key] = value as AnyObject
        }
        UserDefaults.standard.setValue(storeDictionary, forKey: AppConfigStorage.defaultsGlobalConfig)
    }

    
    // --
    // MARK: Observers
    // --
    
    public func addDataObserver(_ observer: NSObject, selector: Selector, name: String) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: self)
    }
    
    public func removeDataObserver(_ observer: NSObject, name: String) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: name), object: self)
    }
    
}
