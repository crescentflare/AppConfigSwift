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
class AppConfigManageTable : UIView, UITableViewDataSource, UITableViewDelegate, AppConfigSelectionPopupViewDelegate {
    
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
        var foundItem: String?
        if let values = AppConfigStorage.shared.configManager()?.obtainBaseModelInstance().obtainValues() {
            for key in AppConfigStorage.shared.storedConfigs.allKeys() {
                if let item = AppConfigStorage.shared.storedConfigs[key] as? [String: Any] {
                    var isEqual = true
                    for (key, value) in item {
                        if let compareValue = values[key] {
                            if value is String {
                                isEqual = value as! String == compareValue as? String
                            } else if value is Int {
                                isEqual = value as! Int == compareValue as? Int
                            } else if value is Float {
                                isEqual = value as! Float == compareValue as? Float
                            } else if value is Double {
                                isEqual = value as! Double == compareValue as? Double
                            } else if value is Bool {
                                isEqual = value as! Bool == compareValue as? Bool
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
        return foundItem
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
            }
        }
        table.deselectRow(at: indexPath, animated: false)
    }
    
    
    // --
    // MARK: AppConfigSelectionPopupViewDelegate
    // --
    
    func selectedItem(_ item: String, token: String?) {
        delegate?.newCustomConfigFrom(configName: item)
    }

}
