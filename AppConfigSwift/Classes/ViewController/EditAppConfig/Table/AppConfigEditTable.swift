//
//  AppConfigEditTable.swift
//  AppConfigSwift Pod
//
//  Library table: edit configuration
//  The table view and data source for the edit config viewcontroller
//  Used internally
//

import UIKit

// Delegate protocol
protocol AppConfigEditTableDelegate: class {

    func saveConfig(_ newSettings: [String: Any])
    func cancelEditing()
    func revertConfig()

}


// Class
open class AppConfigEditTable : UIView, UITableViewDataSource, UITableViewDelegate, AppConfigEditTextCellViewDelegate, AppConfigEditSwitchCellViewDelegate, AppConfigSelectionPopupViewDelegate {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigEditTableDelegate?
    var tableValues: [AppConfigEditTableValue] = []
    var configName: String = ""
    var newConfig: Bool = false
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
    
    public required init?(coder aDecoder: NSCoder) {
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
        AppConfigViewUtility.addPinSuperViewEdgesConstraints(table, parentView: self)
        
        // Set table view properties
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 40
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        // Show loading indicator by default
        tableValues.append(AppConfigEditTableValue.valueForLoading(AppConfigBundle.localizedString("CFLAC_SHARED_LOADING_CONFIGS")))
    }

    
    // --
    // MARK: Implementation
    // --
    
    open func setConfigurationSettings(_ configurationSettings: [String: Any], model: AppConfigBaseModel?) {
        // Add editable fields
        var rawTableValues: [AppConfigEditTableValue] = []
        tableValues = []
        if configurationSettings.count > 0 {
            // First add the name section + field for custom configurations
            let customizedCopy = newConfig || (AppConfigStorage.sharedManager.isCustomConfig(configName ?? "") && !AppConfigStorage.sharedManager.isConfigOverride(configName ?? ""))
            if customizedCopy {
                for (key, value) in configurationSettings {
                    if key == "name" {
                        rawTableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_NAME")))
                        rawTableValues.append(AppConfigEditTableValue.valueForTextEntry(key, andValue: value as? String ?? "", numberOnly: false))
                        break;
                    }
                }
            }

            // Add configuration values
            if let categorizedFields = model?.obtainCategorizedFields() {
                // Using model and optional categories
                let modelValues = model?.obtainValues() ?? [:]
                let hasMultipleCategories = categorizedFields.allKeys().count > 1
                var sortedCategories: [String] = []
                for category in categorizedFields.allKeys() {
                    if category.characters.count > 0 {
                        sortedCategories.append(category)
                    }
                }
                for category in categorizedFields.allKeys() {
                    if category.characters.count == 0 {
                        sortedCategories.append("")
                        break
                    }
                }
                for category in sortedCategories {
                    let categoryName = category.characters.count > 0 ? category : AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_UNCATEGORIZED")
                    var configSectionAdded = false
                    for field in categorizedFields[category] ?? [] {
                        if field == "name" {
                            continue
                        }
                        if !configSectionAdded {
                            var baseCategoryName = ""
                            if customizedCopy {
                                baseCategoryName = AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_SETTINGS")
                            } else {
                                baseCategoryName = configName
                            }
                            if hasMultipleCategories {
                                baseCategoryName += ": " + categoryName
                            }
                            rawTableValues.append(AppConfigEditTableValue.valueForSection(baseCategoryName))
                            configSectionAdded = true
                        }
                        if modelValues[field] is Bool {
                            rawTableValues.append(AppConfigEditTableValue.valueForSwitchValue(field, andSwitchedOn: configurationSettings[field] as? Bool ?? false))
                            continue
                        }
                        if model?.isRawRepresentable(field: field) ?? false {
                            let choices: [String] = model?.getRawRepresentableValues(forField: field) ?? []
                            rawTableValues.append(AppConfigEditTableValue.valueForSelection(field, andValue: configurationSettings[field] as? String ?? "", andChoices: choices))
                            continue
                        }
                        if modelValues[field] is Int {
                            rawTableValues.append(AppConfigEditTableValue.valueForTextEntry(field, andValue: "\(configurationSettings[field] ?? 0)", numberOnly: true))
                        } else {
                            rawTableValues.append(AppConfigEditTableValue.valueForTextEntry(field, andValue: "\(configurationSettings[field] ?? "")", numberOnly: false))
                        }
                    }
                }
            } else {
                // Using raw dictionary
                var configSectionAdded = false
                for (key, value) in configurationSettings {
                    if key == "name" {
                        continue
                    }
                    if !configSectionAdded {
                        if customizedCopy {
                            rawTableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_SETTINGS")))
                        } else {
                            rawTableValues.append(AppConfigEditTableValue.valueForSection(configName))
                        }
                        configSectionAdded = true
                    }
                    if value is Bool {
                        rawTableValues.append(AppConfigEditTableValue.valueForSwitchValue(key, andSwitchedOn: value as? Bool ?? false))
                        continue
                    }
                    rawTableValues.append(AppConfigEditTableValue.valueForTextEntry(key, andValue: "\(value)", numberOnly: value is Int))
                }
            }
        }

        // Add actions
        rawTableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_ACTIONS")))
        if newConfig {
            rawTableValues.append(AppConfigEditTableValue.valueForAction(.Save, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_CREATE")))
        } else {
            rawTableValues.append(AppConfigEditTableValue.valueForAction(.Save, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_APPLY")))
        }
        if !newConfig {
            if !AppConfigStorage.sharedManager.isCustomConfig(configName) || AppConfigStorage.sharedManager.isConfigOverride(configName) {
                rawTableValues.append(AppConfigEditTableValue.valueForAction(.Revert, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_RESET")))
            } else {
                rawTableValues.append(AppConfigEditTableValue.valueForAction(.Revert, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_DELETE")))
            }
        }
        rawTableValues.append(AppConfigEditTableValue.valueForAction(.Cancel, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_CANCEL")))

        // Style table by adding dividers and reload
        var prevType: AppConfigEditTableValueType = .Unknown
        for tableValue in rawTableValues {
            if !prevType.isCellType() && tableValue.type.isCellType() {
                tableValues.append(AppConfigEditTableValue.valueForDivider(.TopDivider))
            } else if prevType.isCellType() && !tableValue.type.isCellType() {
                tableValues.append(AppConfigEditTableValue.valueForDivider(.BottomDivider))
            } else if !prevType.isCellType() && !tableValue.type.isCellType() {
                tableValues.append(AppConfigEditTableValue.valueForDivider(.BetweenDivider))
            }
            tableValues.append(tableValue)
            prevType = tableValue.type
        }
        if prevType.isCellType() {
            tableValues.append(AppConfigEditTableValue.valueForDivider(.BottomDivider))
        } else {
            tableValues.append(AppConfigEditTableValue.valueForDivider(.BetweenDivider))
        }
        table.reloadData()
    }
    
    open func obtainNewConfigurationSettings() -> [String: Any] {
        var result: [String: Any] = [:]
        result["name"] = configName
        for tableValue in tableValues {
            switch tableValue.type {
            case .TextEntry:
                if tableValue.limitUsage {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    result[tableValue.configSetting!] = formatter.number(from: tableValue.labelString)
                } else {
                    result[tableValue.configSetting!] = tableValue.labelString
                }
                break
            case .SwitchValue:
                result[tableValue.configSetting!] = tableValue.booleanValue
                break
            case .Selection:
                result[tableValue.configSetting!] = tableValue.labelString
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
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValues.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell (if needed)
        let tableValue = tableValues[(indexPath as NSIndexPath).row]
        let nextType = (indexPath as NSIndexPath).row + 1 < tableValues.count ? tableValues[(indexPath as NSIndexPath).row + 1].type : AppConfigEditTableValueType.Unknown
        var cell: AppConfigTableCell? = tableView.dequeueReusableCell(withIdentifier: tableValue.type.rawValue) as? AppConfigTableCell
        if cell == nil {
            cell = AppConfigTableCell()
        }
        
        // Set up a loader cell
        if tableValue.type == .Loading {
            // Create view
            var cellView: AppConfigLoadingCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigLoadingCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigLoadingCellView
            }

            // Supply data
            cell?.selectionStyle = .none
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = tableValue.labelString
        }

        // Set up an action cell
        if tableValue.type == .Action {
            // Create view
            var cellView: AppConfigItemCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigItemCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigItemCellView
            }
            
            // Supply data
            cell?.selectionStyle = .default
            cell?.accessoryType = .disclosureIndicator
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = tableValue.labelString
        }
        
        // Set up a text entry cell
        if tableValue.type == .TextEntry {
            // Create view
            var cellView: AppConfigEditTextCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigEditTextCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigEditTextCellView
            }

            // Supply data
            cell?.selectionStyle = .default
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.delegate = self
            cellView!.label = tableValue.configSetting
            cellView!.editedText = tableValue.labelString
            cellView!.applyNumberLimitation = tableValue.limitUsage
        }
        
        // Set up a switch value cell
        if tableValue.type == .SwitchValue {
            // Create view
            var cellView: AppConfigEditSwitchCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigEditSwitchCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigEditSwitchCellView
            }

            // Supply data
            cell?.selectionStyle = .default
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.delegate = self
            cellView!.label = tableValue.configSetting
            cellView!.on = tableValue.booleanValue
        }
        
        // Set up a selection cell (for enums)
        if tableValue.type == .Selection {
            // Create view
            var cellView: AppConfigItemCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigItemCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigItemCellView
            }
            
            // Supply data
            cell?.selectionStyle = .default
            cell?.accessoryType = .disclosureIndicator
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = "\(tableValue.configSetting ?? ""): \(tableValue.labelString)"
        }
        
        // Set up a section cell
        if tableValue.type == .Section {
            // Create view
            var cellView: AppConfigSectionCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigSectionCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigSectionCellView
            }
            
            // Supply data
            cell?.selectionStyle = .none
            cell?.shouldHideDivider = true
            cellView!.label = tableValue.labelString
        }
        
        // Set up a divider cell
        if tableValue.type == .TopDivider || tableValue.type == .BottomDivider || tableValue.type == .BetweenDivider {
            // Create view
            var cellView: AppConfigCellSectionDividerView? = nil
            if cell!.cellView == nil {
                if tableValue.type == .BetweenDivider {
                    cellView = AppConfigCellSectionDividerView()
                } else {
                    cellView = AppConfigCellSectionDividerView(location: tableValue.type == .TopDivider ? .Top : .Bottom)
                }
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigCellSectionDividerView
            }
            
            // Supply data
            cell?.selectionStyle = .none
            cell?.shouldHideDivider = true
        }

        // Return result
        return cell!
    }
    
    
    // --
    // MARK: UITableViewDelegate
    // --
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableValue = tableValues[(indexPath as NSIndexPath).row]
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        if tableValue.type == .Action && delegate != nil {
            switch tableValue.action {
            case .Save:
                delegate?.saveConfig(obtainNewConfigurationSettings())
                break
            case .Cancel:
                delegate?.cancelEditing()
                break
            case .Revert:
                delegate?.revertConfig()
                break
            default:
                break
            }
        } else if tableValue.type == .Selection {
            let choicePopup = AppConfigSelectionPopupView()
            choicePopup.label = tableValue.configSetting
            choicePopup.choices = tableValue.selectionItems ?? []
            choicePopup.delegate = self
            choicePopup.token = tableValue.configSetting
            choicePopup.addToSuperview(self)
            AppConfigViewUtility.addPinSuperViewEdgesConstraints(choicePopup, parentView: self)
        } else if tableValue.type == .SwitchValue {
            if let cell = tableView.cellForRow(at: indexPath) as? AppConfigTableCell {
                if let switchCellView = cell.cellView as? AppConfigEditSwitchCellView {
                    switchCellView.toggleState()
                }
            }
        } else if tableValue.type == .TextEntry {
            if let cell = tableView.cellForRow(at: indexPath) as? AppConfigTableCell {
                if let editTextCellView = cell.cellView as? AppConfigEditTextCellView {
                    editTextCellView.startEditing()
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
                tableValues[i] = AppConfigEditTableValue.valueForTextEntry(tableValue.configSetting!, andValue: newText, numberOnly: tableValue.limitUsage)
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
                tableValues[i] = AppConfigEditTableValue.valueForSwitchValue(tableValue.configSetting!, andSwitchedOn: on)
                break
            }
        }
    }

    
    // --
    // MARK: AppConfigSelectionPopupViewDelegate
    // --
    
    func selectedItem(_ item: String, token: String?) {
        for i in 0..<tableValues.count {
            let tableValue = tableValues[i]
            if tableValue.configSetting == token {
                let totalIndexPath = IndexPath.init(row: i, section: 0)
                tableValues[i] = AppConfigEditTableValue.valueForSelection(tableValue.configSetting!, andValue: item, andChoices: tableValue.selectionItems!)
                table.beginUpdates()
                table.reloadRows(at: [totalIndexPath], with: .none)
                table.endUpdates()
                break
            }
        }
    }
    
}
