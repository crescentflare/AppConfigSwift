//
//  AppConfigEditTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: edit configuration
//  A table model with different table cell types for the edit config viewcontroller
//  Used internally
//

// Value type enum
enum AppConfigEditTableValueType: String {
    
    case unknown = "unknown"
    case loading = "loading"
    case action = "action"
    case textEntry = "text_entry"
    case switchValue = "switch_value"
    case selection = "selection"
    case section = "section"
    case topDivider = "topDivider"
    case bottomDivider = "bottomDivider"
    case betweenDivider = "betweenDivider"
    
    func isCellType() -> Bool {
        return self == .loading || self == .action || self == .textEntry || self == .switchValue || self == .selection
    }

}

// Action type enum
enum AppConfigEditTableActionType: String {
    
    case none = "none"
    case save = "save"
    case cancel = "cancel"
    case revert = "revert"
    
}

// Table value
class AppConfigEditTableValue {
    
    // --
    // MARK: Members
    // --
    
    let configSetting: String?
    let labelString: String
    let booleanValue: Bool
    let limitUsage: Bool
    let selectionItems: [String]?
    let action: AppConfigEditTableActionType
    let type: AppConfigEditTableValueType

    
    // --
    // MARK: Initialization
    // --
    
    init(configSetting: String?, labelString: String, booleanValue: Bool, limitUsage: Bool, selectionItems: [String]?, action: AppConfigEditTableActionType, type: AppConfigEditTableValueType) {
        self.configSetting = configSetting
        self.labelString = labelString
        self.booleanValue = booleanValue
        self.limitUsage = limitUsage
        self.selectionItems = selectionItems
        self.action = action
        self.type = type
    }
    

    // --
    // MARK: Factory methods
    // --
    
    static func valueForLoading(text: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, action: .none, type: .loading)
    }
    
    static func valueForAction(_ action: AppConfigEditTableActionType, andText: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: andText, booleanValue: false, limitUsage: false, selectionItems: nil, action: action, type: .action)
    }
    
    static func valueForTextEntry(configSetting: String, andValue: String, numberOnly: Bool) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: numberOnly, selectionItems: nil, action: .none, type: .textEntry)
    }
    
    static func valueForSwitchValue(configSetting: String, andSwitchedOn: Bool) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: "", booleanValue: andSwitchedOn, limitUsage: false, selectionItems: nil, action: .none, type: .switchValue)
    }

    static func valueForSelection(configSetting: String, andValue: String, andChoices: [String]) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: false, selectionItems: andChoices, action: .none, type: .selection)
    }

    static func valueForSection(text: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, action: .none, type: .section)
    }

    static func valueForDivider(type: AppConfigEditTableValueType) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: "", booleanValue: false, limitUsage: false, selectionItems: nil, action: .none, type: type)
    }

}
