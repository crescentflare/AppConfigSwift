//
//  AppConfigBaseManager.swift
//  AppConfigSwift Pod
//
//  Library manager: base manager for app customization
//  Derive your custom config manager from this class for integration
//

open class AppConfigBaseManager {

    // --
    // MARK: Members
    // --
    
    var currentConfig: AppConfigBaseModel?
    var plugins: [AppConfigPlugin] = []

    
    // --
    // MARK: Initialization
    // --
    
    public init() { }
    
    
    // --
    // MARK: Fetch model
    // --

    // Obtain a new instance of the configuration model
    // Override in your derived manager (check the example for details)
    open func obtainBaseModelInstance() -> AppConfigBaseModel {
        return AppConfigBaseModel()
    }
    
    // Used by the derived manager to return the selected configuration instance
    // Will usually be typecasted to the specific model class for the app
    public func currentConfigInstance() -> AppConfigBaseModel {
        currentConfig = currentConfig ?? obtainBaseModelInstance()
        return currentConfig!
    }
    
    // Internal method to apply a new configuration selection to the model
    public func applyConfigToModel(config: [String: Any], globalConfig: [String: Any], name: String?) {
        currentConfig = obtainBaseModelInstance()
        currentConfig?.apply(overrides: config, globalOverrides: globalConfig, name: name)
    }
    

    // --
    // MARK: Plugins
    // --
    
    // Append the list of custom plugins
    public func addPlugin(_ plugin: AppConfigPlugin) {
        plugins.append(plugin)
    }
    
    // Manually set all custom plugins
    public func setPlugins(_ plugins: [AppConfigPlugin]) {
        self.plugins = plugins
    }
    
    // Remove all custom plugins
    public func removeAllPlugins() {
        plugins = []
    }
    
}
