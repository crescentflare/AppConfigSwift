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
    
}

public class AppConfigManageTableValue {
    
    // --
    // MARK: Members
    // --
    
    let config: String?
    let labelString: String
    let type: AppConfigManageTableValueType

    
    // --
    // MARK: Initialization
    // --
    
    public init(config: String?, labelString: String, type: AppConfigManageTableValueType) {
        self.config = config
        self.labelString = labelString
        self.type = type
    }
    

    // --
    // MARK: Factory methods
    // --
    
    public static func valueForLoading(loadingText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: loadingText, type: .Loading)
    }
    
    public static func valueForConfig(configName: String?, andText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: configName, labelString: andText, type: .Config)
    }
    
    public static func valueForInfo(infoText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: infoText, type: .Info)
    }
    
    public static func valueForSection(sectionText: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, labelString: sectionText, type: .Section)
    }
    
}
