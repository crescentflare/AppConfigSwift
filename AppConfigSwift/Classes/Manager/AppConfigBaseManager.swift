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
    public func applyConfigToModel(config: [String: Any], name: String?) {
        currentConfig = obtainBaseModelInstance()
        currentConfig?.apply(overrides: config, name: name)
    }
    
}
