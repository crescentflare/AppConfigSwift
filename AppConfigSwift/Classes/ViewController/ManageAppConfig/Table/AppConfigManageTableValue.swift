//
//  AppConfigManageTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: managing configurations
//  A table model with different table cell types for the manage config viewcontroller
//  Used internally
//

//Value type enum
enum AppConfigManageTableValueType: String {
    
    case Unknown = "unknown"
    case Loading = "loading"
    case Config = "config"
    case Info = "info"
    case Section = "section"
    case TopDivider = "topDivider"
    case BottomDivider = "bottomDivider"
    case BetweenDivider = "betweenDivider"
    
    public func isCellType() -> Bool {
        return self == .Config || self == .Info || self == .Loading
    }
    
}

class AppConfigManageTableValue {
    
    // --
    // MARK: Members
    // --
    
    let config: String?
    let labelString: String
    let lastSelected: Bool
    let edited: Bool
    let type: AppConfigManageTableValueType

    
    // --
    // MARK: Initialization
    // --
    
    init(config: String?, labelString: String, type: AppConfigManageTableValueType, lastSelected: Bool, edited: Bool) {
        self.config = config
        self.labelString = labelString
        self.type = type
        self.lastSelected = lastSelected
        self.edited = edited
    }
    

    // --
    // MARK: Factory methods
    // --
    
    static func valueForLoading(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: text, type: .Loading, lastSelected: false, edited: false)
    }
    
    static func valueForConfig(name: String?, andText: String, lastSelected: Bool, edited: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: name, labelString: andText, type: .Config, lastSelected: lastSelected, edited: edited)
    }
    
    static func valueForInfo(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: text, type: .Info, lastSelected: false, edited: false)
    }
    
    static func valueForSection(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: text, type: .Section, lastSelected: false, edited: false)
    }
    
    static func valueForDivider(type: AppConfigManageTableValueType) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: "", type: type, lastSelected: false, edited: false)
    }
    
}
