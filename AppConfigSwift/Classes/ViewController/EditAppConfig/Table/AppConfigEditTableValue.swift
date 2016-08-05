//
//  AppConfigEditTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: edit configuration
//  A table model with different table cell types for the edit config viewcontroller
//  Used internally
//

//Value type enum
public enum AppConfigEditTableValueType: String {
    
    case Unknown = "unknown"
    case Loading = "loading"
    case Action = "action"
    case TextEntry = "text_entry"
    case SwitchValue = "switch_value"
    case Selection = "selection"
    case Section = "section"
    case TopDivider = "topDivider"
    case BottomDivider = "bottomDivider"
    case BetweenDivider = "betweenDivider"
    
    func isCellType() -> Bool {
        return self == .Loading || self == .Action || self == .TextEntry || self == .SwitchValue || self == .Selection
    }

}

//Action type enum
public enum AppConfigEditTableActionType: String {
    
    case None = "none"
    case Save = "save"
    case Cancel = "cancel"
    case Revert = "revert"
    
}

public class AppConfigEditTableValue {
    
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
    
    public init(configSetting: String?, labelString: String, booleanValue: Bool, limitUsage: Bool, selectionItems: [String]?, action: AppConfigEditTableActionType, type: AppConfigEditTableValueType) {
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
    
    public static func valueForLoading(loadingText: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: loadingText, booleanValue: false, limitUsage: false, selectionItems: nil, action: .None, type: .Loading)
    }
    
    public static func valueForAction(action: AppConfigEditTableActionType, andText: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: andText, booleanValue: false, limitUsage: false, selectionItems: nil, action: action, type: .Action)
    }
    
    public static func valueForTextEntry(configSetting: String, andValue: String, numberOnly: Bool) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: numberOnly, selectionItems: nil, action: .None, type: .TextEntry)
    }
    
    public static func valueForSwitchValue(configSetting: String, andSwitchedOn: Bool) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: "", booleanValue: andSwitchedOn, limitUsage: false, selectionItems: nil, action: .None, type: .SwitchValue)
    }

    public static func valueForSelection(configSetting: String, andValue: String, andChoices: [String]) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: false, selectionItems: andChoices, action: .None, type: .Selection)
    }

    public static func valueForSection(sectionText: String) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: sectionText, booleanValue: false, limitUsage: false, selectionItems: nil, action: .None, type: .Section)
    }

    public static func valueForDivider(type: AppConfigEditTableValueType) -> AppConfigEditTableValue {
        return AppConfigEditTableValue(configSetting: nil, labelString: "", booleanValue: false, limitUsage: false, selectionItems: nil, action: .None, type: type)
    }

}
