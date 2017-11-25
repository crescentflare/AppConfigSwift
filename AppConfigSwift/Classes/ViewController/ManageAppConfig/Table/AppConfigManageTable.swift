//
//  AppConfigManageTable.swift
//  AppConfigSwift Pod
//
//  Library table: managing configurations
//  The table view and data source for the manage config viewcontroller
//  Used internally
//

import UIKit

// Delegate protocol
protocol AppConfigManageTableDelegate: class {

    func selectedConfig(configName: String)
    func editConfig(configName: String)
    func newCustomConfigFrom(configName: String)

}


// Class
class AppConfigManageTable : UIView, UITableViewDataSource, UITableViewDelegate, AppConfigEditTextCellViewDelegate, AppConfigEditSwitchCellViewDelegate, AppConfigSelectionPopupViewDelegate {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigManageTableDelegate?
    var tableValues: [AppConfigManageTableValue] = []
    let table = UITableView()

    
    // --
    // MARK: Initialization
    // --
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize () {
        // Set up table view
        let tableFooter = UIView()
        table.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        tableFooter.frame = CGRect(x: 0, y: 0, width: 0, height: 8)
        table.tableFooterView = tableFooter
        addSubview(table)
        AppConfigViewUtility.addPinSuperViewEdgesConstraints(view: table, parentView: self)
        
        // Set table view properties
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 40
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        // Show loading indicator by default
        tableValues.append(AppConfigManageTableValue.valueForLoading(text: AppConfigBundle.localizedString(key: "CFLAC_SHARED_LOADING_CONFIGS")))
    }

    
    // --
    // MARK: Implementation
    // --
    
    private func findDefaultConfig() -> String? {
        if let values = AppConfigStorage.shared.configManager()?.obtainBaseModelInstance().obtainConfigurationValues() {
            for key in AppConfigStorage.shared.storedConfigs.allKeys() {
                if let item = AppConfigStorage.shared.storedConfigs[key] as? [String: Any] {
                    var isEqual = true
                    for (key, value) in item {
                        if let compareValue = values[key] {
                            if value is String {
                                isEqual = value as? String == compareValue as? String
                            } else if value is Int {
                                isEqual = value as? Int == compareValue as? Int
                            } else if value is Float {
                                isEqual = value as? Float == compareValue as? Float
                            } else if value is Double {
                                isEqual = value as? Double == compareValue as? Double
                            } else if value is Bool {
                                isEqual = value as? Bool == compareValue as? Bool
                            } else {
                                isEqual = false
                            }
                            if !isEqual {
                                break
                            }
                        } else {
                            isEqual = false
                            break
                        }
                    }
                    if isEqual {
                        return key
                    }
                }
            }
        }
        return nil
    }
    
    func setConfigurations(_ configurations: [String], customConfigurations: [String], lastSelected: String?) {
        // Set selected and if not set, check against default config in model
        var selected = lastSelected
        if selected == nil {
            selected = findDefaultConfig()
        }
        
        // Start with an empty table values list
        var rawTableValues: [AppConfigManageTableValue] = []
        tableValues = []
        
        // Add predefined configurations (if present)
        if configurations.count > 0 {
            rawTableValues.append(AppConfigManageTableValue.valueForSection(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_PREDEFINED")))
            for configuration: String in configurations {
                rawTableValues.append(AppConfigManageTableValue.valueForConfig(name: configuration, andText: configuration, lastSelected: configuration == selected, edited: AppConfigStorage.shared.isConfigOverride(config: configuration)))
            }
        }
        
        // Add custom configurations (if present)
        if configurations.count > 0 {
            rawTableValues.append(AppConfigManageTableValue.valueForSection(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_CUSTOM")))
            for configuration: String in customConfigurations {
                rawTableValues.append(AppConfigManageTableValue.valueForConfig(name: configuration, andText: configuration, lastSelected: configuration == selected, edited: false))
            }
            rawTableValues.append(AppConfigManageTableValue.valueForConfig(name: nil, andText: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_ADD_NEW"), lastSelected: false, edited: false))
        }
        
        // Add global settings
        let settings = AppConfigStorage.shared.globalConfig
        let model = AppConfigStorage.shared.configManager()?.obtainBaseModelInstance()
        model?.apply(overrides: [:], globalOverrides: settings, name: "Global")
        if settings.count > 0 || (model?.obtainGlobalValues().count ?? 0) > 0 {
            if let categorizedFields = model?.obtainGlobalCategorizedFields() {
                // Using model and optional categories
                let modelValues = model?.obtainGlobalValues() ?? [:]
                let hasMultipleCategories = categorizedFields.allKeys().count > 1
                var sortedCategories: [String] = []
                for category in categorizedFields.allKeys() {
                    if category.count > 0 {
                        sortedCategories.append(category)
                    }
                }
                for category in categorizedFields.allKeys() {
                    if category.count == 0 {
                        sortedCategories.append("")
                        break
                    }
                }
                for category in sortedCategories {
                    let categoryName = category.count > 0 ? category : AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_GLOBALS_UNCATEGORIZED")
                    var configSectionAdded = false
                    for field in categorizedFields[category] ?? [] {
                        if !configSectionAdded {
                            var baseCategoryName = ""
                            baseCategoryName = AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_GLOBALS")
                            if hasMultipleCategories {
                                baseCategoryName += ": " + categoryName
                            }
                            rawTableValues.append(AppConfigManageTableValue.valueForSection(text: baseCategoryName))
                            configSectionAdded = true
                        }
                        if modelValues[field] is Bool {
                            rawTableValues.append(AppConfigManageTableValue.valueForSwitchValue(configSetting: field, andSwitchedOn: modelValues[field] as? Bool ?? false))
                            continue
                        }
                        if model?.isRawRepresentable(field: field) ?? false {
                            let choices: [String] = model?.getRawRepresentableValues(forField: field) ?? []
                            rawTableValues.append(AppConfigManageTableValue.valueForSelection(configSetting: field, andValue: modelValues[field] as? String ?? "", andChoices: choices))
                            continue
                        }
                        if modelValues[field] is Int {
                            rawTableValues.append(AppConfigManageTableValue.valueForTextEntry(configSetting: field, andValue: "\(modelValues[field] as? Int ?? 0)", numberOnly: true))
                        } else {
                            rawTableValues.append(AppConfigManageTableValue.valueForTextEntry(configSetting: field, andValue: "\(modelValues[field] as? String ?? "")", numberOnly: false))
                        }
                    }
                }
            } else {
                // Using raw dictionary
                var configSectionAdded = false
                for (key, value) in settings {
                    if !configSectionAdded {
                        rawTableValues.append(AppConfigManageTableValue.valueForSection(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_GLOBALS")))
                        configSectionAdded = true
                    }
                    if value is Bool {
                        rawTableValues.append(AppConfigManageTableValue.valueForSwitchValue(configSetting: key, andSwitchedOn: value as? Bool ?? false))
                        continue
                    }
                    rawTableValues.append(AppConfigManageTableValue.valueForTextEntry(configSetting: key, andValue: "\(value)", numberOnly: value is Int))
                }
            }
        }

        // Add build information
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        rawTableValues.append(AppConfigManageTableValue.valueForSection(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SECTION_BUILD_INFO")))
        rawTableValues.append(AppConfigManageTableValue.valueForInfo(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_BUILD_NR") + ": " + bundleVersion))
        rawTableValues.append(AppConfigManageTableValue.valueForInfo(text: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_BUILD_IOS_VERSION") + ": " + UIDevice.current.systemVersion))
        
        // Style table by adding dividers and reload
        var prevType: AppConfigManageTableValueType = .unknown
        for tableValue in rawTableValues {
            if !prevType.isCellType() && tableValue.type.isCellType() {
                tableValues.append(AppConfigManageTableValue.valueForDivider(type: .topDivider))
            } else if prevType.isCellType() && !tableValue.type.isCellType() {
                tableValues.append(AppConfigManageTableValue.valueForDivider(type: .bottomDivider))
            } else if !prevType.isCellType() && !tableValue.type.isCellType() {
                tableValues.append(AppConfigManageTableValue.valueForDivider(type: .betweenDivider))
            }
            tableValues.append(tableValue)
            prevType = tableValue.type
        }
        if prevType.isCellType() {
            tableValues.append(AppConfigManageTableValue.valueForDivider(type: .bottomDivider))
        } else {
            tableValues.append(AppConfigManageTableValue.valueForDivider(type: .betweenDivider))
        }
        table.reloadData()
    }
    
    func obtainNewGlobalSettings() -> [String: Any] {
        var result: [String: Any] = [:]
        for tableValue in tableValues {
            switch tableValue.type {
            case .textEntry:
                if tableValue.limitUsage {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    result[tableValue.configSetting!] = formatter.number(from: tableValue.labelString)
                } else {
                    result[tableValue.configSetting!] = tableValue.labelString
                }
                break
            case .switchValue:
                result[tableValue.configSetting!] = tableValue.booleanValue
                break
            case .selection:
                if tableValue.configSetting != nil { // Can be nil, in case of a new custom configuration
                    result[tableValue.configSetting!] = tableValue.labelString
                }
                break
            default:
                break // Others are not editable cells
            }
        }
        return result
    }

    
    // --
    // MARK: UITableViewDataSource
    // --
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell (if needed)
        let tableValue = tableValues[(indexPath as NSIndexPath).row]
        let nextType = (indexPath as NSIndexPath).row + 1 < tableValues.count ? tableValues[(indexPath as NSIndexPath).row + 1].type : AppConfigManageTableValueType.unknown
        let cell = tableView.dequeueReusableCell(withIdentifier: tableValue.type.rawValue) as? AppConfigTableCell ?? AppConfigTableCell()
        
        // Set up a loader cell
        if tableValue.type == .loading {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigLoadingCellView()
            }
            let cellView = cell.cellView as? AppConfigLoadingCellView

            // Supply data
            cell.selectionStyle = .none
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.label = tableValue.labelString
        }
        
        // Set up a config cell
        if tableValue.type == .config {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigItemCellView()
            }
            let cellView = cell.cellView as? AppConfigItemCellView
            
            // Supply data
            cell.accessoryType = tableValue.lastSelected ? .checkmark : .disclosureIndicator
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.label = tableValue.labelString
            cellView?.additional = tableValue.edited ? AppConfigBundle.localizedString(key: "CFLAC_MANAGE_INDICATOR_EDITED") : ""
        }
        
        // Set up an info cell
        if tableValue.type == .info {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigManageInfoCellView()
            }
            let cellView = cell.cellView as? AppConfigManageInfoCellView
            
            // Supply data
            cell.selectionStyle = .none
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.label = tableValue.labelString
        }
        
        // Set up a text entry cell
        if tableValue.type == .textEntry {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigEditTextCellView()
            }
            let cellView = cell.cellView as? AppConfigEditTextCellView
            
            // Supply data
            cell.selectionStyle = .default
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.delegate = self
            cellView?.label = tableValue.configSetting
            cellView?.editedText = tableValue.labelString
            cellView?.applyNumberLimitation = tableValue.limitUsage
        }
        
        // Set up a switch value cell
        if tableValue.type == .switchValue {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigEditSwitchCellView()
            }
            let cellView = cell.cellView as? AppConfigEditSwitchCellView
            
            // Supply data
            cell.selectionStyle = .default
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.delegate = self
            cellView?.label = tableValue.configSetting
            cellView?.on = tableValue.booleanValue
        }
        
        // Set up a selection cell (for enums)
        if tableValue.type == .selection {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigItemCellView()
            }
            let cellView = cell.cellView as? AppConfigItemCellView
            
            // Supply data
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
            cell.shouldHideDivider = !nextType.isCellType()
            cellView?.label = "\(tableValue.configSetting ?? ""): \(tableValue.labelString)"
        }

        // Set up a section cell
        if tableValue.type == .section {
            // Create view
            if cell.cellView == nil {
                cell.cellView = AppConfigSectionCellView()
            }
            let cellView = cell.cellView as? AppConfigSectionCellView
            
            // Supply data
            cell.selectionStyle = .none
            cell.shouldHideDivider = true
            cellView?.label = tableValue.labelString
        }
        
        // Set up a divider cell
        if tableValue.type == .topDivider || tableValue.type == .bottomDivider || tableValue.type == .betweenDivider {
            // Create view
            if cell.cellView == nil {
                if tableValue.type == .betweenDivider {
                    cell.cellView = AppConfigCellSectionDividerView()
                } else {
                    cell.cellView = AppConfigCellSectionDividerView(location: tableValue.type == .topDivider ? .top : .bottom)
                }
            }

            // Supply data
            cell.selectionStyle = .none
            cell.shouldHideDivider = true
        }
        
        // Return result
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let tableValue = tableValues[(indexPath as NSIndexPath).row]
        return tableValue.type == .config && tableValue.config != nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction.init(style: .normal, title: AppConfigBundle.localizedString(key: "CFLAC_MANAGE_SWIPE_EDIT"), handler: { action, indexPath in
            let tableValue = self.tableValues[(indexPath as NSIndexPath).row]
            tableView.setEditing(false, animated: true)
            if tableValue.config != nil {
                self.delegate?.editConfig(configName: tableValue.config!)
            }
        })
        editAction.backgroundColor = UIColor.blue
        return [editAction]
    }
    
    
    // --
    // MARK: UITableViewDelegate
    // --
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableValue = tableValues[(indexPath as NSIndexPath).row]
        if delegate != nil {
            if tableValue.config != nil {
                delegate?.selectedConfig(configName: tableValue.config!)
            } else if tableValue.type == .config {
                let choicePopup = AppConfigSelectionPopupView()
                choicePopup.label = AppConfigBundle.localizedString(key: "CFLAC_SHARED_SELECT_MENU")
                choicePopup.choices = AppConfigStorage.shared.obtainConfigList()
                choicePopup.delegate = self
                choicePopup.addToSuperview(self)
                AppConfigViewUtility.addPinSuperViewEdgesConstraints(view: choicePopup, parentView: self)
            } else if tableValue.type == .selection {
                let choicePopup = AppConfigSelectionPopupView()
                choicePopup.label = tableValue.configSetting
                choicePopup.choices = tableValue.selectionItems ?? []
                choicePopup.delegate = self
                choicePopup.token = tableValue.configSetting
                choicePopup.addToSuperview(self)
                AppConfigViewUtility.addPinSuperViewEdgesConstraints(view: choicePopup, parentView: self)
            } else if tableValue.type == .switchValue {
                if let cell = tableView.cellForRow(at: indexPath) as? AppConfigTableCell {
                    if let switchCellView = cell.cellView as? AppConfigEditSwitchCellView {
                        switchCellView.toggleState()
                    }
                }
            } else if tableValue.type == .textEntry {
                if let cell = tableView.cellForRow(at: indexPath) as? AppConfigTableCell {
                    if let editTextCellView = cell.cellView as? AppConfigEditTextCellView {
                        editTextCellView.startEditing()
                    }
                }
            }
        }
        table.deselectRow(at: indexPath, animated: false)
    }
    
    
    // --
    // MARK: AppConfigEditTextCellViewDelegate
    // --
    
    func changedEditText(_ newText: String, forConfigSetting: String) {
        for i in 0..<tableValues.count {
            let tableValue = tableValues[i]
            if tableValue.configSetting == forConfigSetting {
                tableValues[i] = AppConfigManageTableValue.valueForTextEntry(configSetting: tableValue.configSetting!, andValue: newText, numberOnly: tableValue.limitUsage)
                break
            }
        }
    }
    
    
    // --
    // MARK: AppConfigEditSwitchCellViewDelegate
    // --
    
    func changedSwitchState(_ on: Bool, forConfigSetting: String) {
        for i in 0..<tableValues.count {
            let tableValue = tableValues[i]
            if tableValue.configSetting == forConfigSetting {
                tableValues[i] = AppConfigManageTableValue.valueForSwitchValue(configSetting: tableValue.configSetting!, andSwitchedOn: on)
                break
            }
        }
    }
    
    
    // --
    // MARK: AppConfigSelectionPopupViewDelegate
    // --
    
    func selectedItem(_ item: String, token: String?) {
        var foundConfigSetting = false
        if token != nil {
            for i in 0..<tableValues.count {
                let tableValue = tableValues[i]
                if tableValue.configSetting == token {
                    let totalIndexPath = IndexPath.init(row: i, section: 0)
                    tableValues[i] = AppConfigManageTableValue.valueForSelection(configSetting: tableValue.configSetting!, andValue: item, andChoices: tableValue.selectionItems!)
                    table.beginUpdates()
                    table.reloadRows(at: [totalIndexPath], with: .none)
                    table.endUpdates()
                    foundConfigSetting = true
                    break
                }
            }
        }
        if !foundConfigSetting {
            delegate?.newCustomConfigFrom(configName: item)
        }
    }

}
