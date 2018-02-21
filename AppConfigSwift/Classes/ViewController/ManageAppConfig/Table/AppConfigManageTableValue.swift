//
//  AppConfigManageTableValue.swift
//  AppConfigSwift Pod
//
//  Library table value: managing configurations
//  A table model with different table cell types for the manage config viewcontroller
//  Used internally

import UIKit

// Value type enum
public enum AppConfigManageTableValueType {
    public enum DividerType {
        case top, bottom, between
    }
    
    case unknown
    case loading
    case config
    case info
    case textEntry
    case switchValue
    case selection
    case section
    case divider(type: DividerType)
    case viewController(title: String, viewControllerClass: UIViewController.Type)
    
    public func isCellType() -> Bool {
        let isCellType: Bool
        switch self {
        case .unknown: isCellType = false
        case .loading: isCellType = true
        case .config: isCellType = true
        case .info: isCellType = true
        case .textEntry: isCellType = true
        case .switchValue: isCellType = true
        case .selection: isCellType = true
        case .section: isCellType = false
        case .divider: isCellType = false
        case .viewController: isCellType = true
        }
        return isCellType
    }
    
    public var identifier: String {
        let identifier: String
        switch self {
        case .unknown: identifier = "unknown"
        case .loading: identifier = "loading"
        case .config: identifier = "config"
        case .info: identifier = "info"
        case .textEntry: identifier = "textEntry"
        case .switchValue: identifier = "switchValue"
        case .selection: identifier = "selection"
        case .section: identifier = "section"
        case .divider: identifier = "divider"
        case .viewController: identifier = "viewController"
        }
        return identifier
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
    let lastSelected: Bool
    let edited: Bool
    let type: AppConfigManageTableValueType

    
    // --
    // MARK: Initialization
    // --
    
    init(config: String?, configSetting: String?, labelString: String, booleanValue: Bool, limitUsage: Bool, selectionItems: [String]?, type: AppConfigManageTableValueType, lastSelected: Bool, edited: Bool) {
        self.config = config
        self.configSetting = configSetting
        self.labelString = labelString
        self.booleanValue = booleanValue
        self.limitUsage = limitUsage
        self.selectionItems = selectionItems
        self.type = type
        self.lastSelected = lastSelected
        self.edited = edited
    }
    
    
    // --
    // MARK: Factory methods
    // --
    
    static func valueForLoading(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, type: .loading, lastSelected: false, edited: false)
    }
    
    static func valueForConfig(name: String?, andText: String, lastSelected: Bool, edited: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: name, configSetting: nil, labelString: andText, booleanValue: false, limitUsage: false, selectionItems: nil, type: .config, lastSelected: lastSelected, edited: edited)
    }
    
    static func valueForInfo(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, type: .info, lastSelected: false, edited: false)
    }
    
    static func valueForTextEntry(configSetting: String, andValue: String, numberOnly: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: numberOnly, selectionItems: nil, type: .textEntry, lastSelected: false, edited: false)
    }
    
    static func valueForSwitchValue(configSetting: String, andSwitchedOn: Bool) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: "", booleanValue: andSwitchedOn, limitUsage: false, selectionItems: nil, type: .switchValue, lastSelected: false, edited: false)
    }
    
    static func valueForSelection(configSetting: String, andValue: String, andChoices: [String]) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: configSetting, labelString: andValue, booleanValue: false, limitUsage: false, selectionItems: andChoices, type: .selection, lastSelected: false, edited: false)
    }

    static func valueForSection(text: String) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: text, booleanValue: false, limitUsage: false, selectionItems: nil, type: .section, lastSelected: false, edited: false)
    }
    
    static func valueForDivider(type: AppConfigManageTableValueType) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: "", booleanValue: false, limitUsage: false, selectionItems: nil, type: type, lastSelected: false, edited: false)
    }

    static func valueForCustomViewController(title: String, viewControllerClass: UIViewController.Type) -> AppConfigManageTableValue {
        return AppConfigManageTableValue(config: nil, configSetting: nil, labelString: title, booleanValue: false, limitUsage: false, selectionItems: nil, type: .viewController(title: title, viewControllerClass: viewControllerClass), lastSelected: false, edited: false)
    }
    
}
