//
//  AppConfigManageTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: managing configurations
//  A table model with different table cell types for the manage config viewcontroller
//  Used internally
//

// Value type enum
enum AppConfigManageTableValueType: String {
    
    case unknown = "unknown"
    case loading = "loading"
    case config = "config"
    case info = "info"
    case textEntry = "textEntry"
    case switchValue = "switchValue"
    case selection = "selection"
    case plugin = "plugin"
    case section = "section"
    case topDivider = "topDivider"
    case bottomDivider = "bottomDivider"
    case betweenDivider = "betweenDivider"
    
    public func isCellType() -> Bool {
        return self == .config || self == .info || self == .loading || self == .textEntry || self == .switchValue || self == .selection || self == .plugin
    }
    
}

// Table value
class AppConfigManageTableValue {
    
    // --
    // MARK: Members
    // --
    
    let config: String?
    let configSetting: String?
    let labelString: String
    let booleanValue: Bool
    let limitUsage: Bool
    let selectionItems: [String]?
    let plugin: AppConfigPlugin?
    let lastSelected: Bool
    let edited: Bool
    let type: AppConfigManageTableValueType

    
    // --
    // MARK: Initialization
    // --
    
    init(config: String?, configSetting: String?, labelString: String, booleanValue: Bool, limitUsage: Bool, selectionItems: [String]?, plugin: AppConfigPlugin?, type: AppConfigManageTableValueType, lastSelected: Bool, edited: Bool) {
        self.config = config
        self.configSetting = configSetting
        self.labelString = labelString
        self.booleanValue = booleanValue
        self.limitUsage = limitUsage
        self.selectionItems = selectionItems
        self.plugin = plugin
        self.type = type
        self.lastSelected = lastSelected
        self.edited = edited
    }
    
    
    // --
    // MARK: Factory methods
    // --
    
    static func valueForLoading(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, plugin: nil, type: .loading, lastSelected: false, edited: false)
    }
    
    static func valueForConfig(name: String?, andText: String, lastSelected: Bool, edited: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: name, configSetting: nil, labelString: andText, booleanValue: false, limitUsage: false, selectionItems: nil, plugin: nil, type: .config, lastSelected: lastSelected, edited: edited)
    }
    
    static func valueForInfo(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, plugin: nil, type: .info, lastSelected: false, edited: false)
    }
    
    static func valueForTextEntry(configSetting: String, andValue: String, numberOnly: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: numberOnly, selectionItems: nil, plugin: nil, type: .textEntry, lastSelected: false, edited: false)
    }
    
    static func valueForSwitchValue(configSetting: String, andSwitchedOn: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: "", booleanValue: andSwitchedOn, limitUsage: false, selectionItems: nil, plugin: nil, type: .switchValue, lastSelected: false, edited: false)
    }
    
    static func valueForSelection(configSetting: String, andValue: String, andChoices: [String]) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: false, selectionItems: andChoices, plugin: nil, type: .selection, lastSelected: false, edited: false)
    }

    static func valueForPlugin(_ plugin: AppConfigPlugin) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: "", booleanValue: false, limitUsage: false, selectionItems: nil, plugin: plugin, type: .plugin, lastSelected: false, edited: false)
    }

    static func valueForSection(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, plugin: nil, type: .section, lastSelected: false, edited: false)
    }
    
    static func valueForDivider(type: AppConfigManageTableValueType) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: "", booleanValue: false, limitUsage: false, selectionItems: nil, plugin: nil, type: type, lastSelected: false, edited: false)
    }
    
}
