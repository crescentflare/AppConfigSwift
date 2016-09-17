//
//  AppConfigManageTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: managing configurations
//  A table model with different table cell types for the manage config viewcontroller
//  Used internally
//

//Value type enum
public enum AppConfigManageTableValueType: String {
    
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

open class AppConfigManageTableValue {
    
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
    
    public init(config: String?, labelString: String, type: AppConfigManageTableValueType, lastSelected: Bool, edited: Bool) {
        self.config = config
        self.labelString = labelString
        self.type = type
        self.lastSelected = lastSelected
        self.edited = edited
    }
    

    // --
    // MARK: Factory methods
    // --
    
    open static func valueForLoading(_ loadingText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: loadingText, type: .Loading, lastSelected: false, edited: false)
    }
    
    open static func valueForConfig(_ configName: String?, andText: String, lastSelected: Bool, edited: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: configName, labelString: andText, type: .Config, lastSelected: lastSelected, edited: edited)
    }
    
    open static func valueForInfo(_ infoText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: infoText, type: .Info, lastSelected: false, edited: false)
    }
    
    open static func valueForSection(_ sectionText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: sectionText, type: .Section, lastSelected: false, edited: false)
    }
    
    open static func valueForDivider(_ type: AppConfigManageTableValueType) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: "", type: type, lastSelected: false, edited: false)
    }
    
}
