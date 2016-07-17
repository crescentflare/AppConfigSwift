//
//  AppConfigEditTable.swift
//  AppConfigSwift Pod
//
//  Library table: edit configuration
//  The table view and data source for the edit config viewcontroller
//  Used internally
//

import UIKit

//Delegate protocol
protocol AppConfigEditTableDelegate: class {

    func saveConfig(newSettings: [String: AnyObject])
    func cancelEditing()
    func revertConfig()

}


//Class
public class AppConfigEditTable : UIView, UITableViewDataSource, UITableViewDelegate, AppConfigSelectionPopupViewDelegate {
    
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
        //Set up table view
        let tableFooter = UIView()
        table.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        tableFooter.frame = CGRectMake(0, 0, 0, 8)
        table.tableFooterView = tableFooter
        addSubview(table)
        AppConfigViewUtility.addPinSuperViewEdgesConstraints(table, parentView: self)
        
        //Set table view properties
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 40
        table.dataSource = self
        table.delegate = self
        
        //Show loading indicator by default
        tableValues.append(AppConfigEditTableValue.valueForLoading(AppConfigBundle.localizedString("CFLAC_SHARED_LOADING_CONFIGS")))
    }

    
    // --
    // MARK: Implementation
    // --
    
    public func setConfigurationSettings(configurationSettings: [String: Any], model: AppConfigBaseModel?) {
        //Add editable fields
        var configSectionAdded = false
        let modelValues = model?.obtainValues()
        tableValues = []
        if configurationSettings.count > 0 {
            let customizedCopy = newConfig || (AppConfigStorage.sharedManager.isCustomConfig(configName ?? "") && !AppConfigStorage.sharedManager.isConfigOverride(configName ?? ""))
            if customizedCopy {
                for (key, value) in configurationSettings {
                    if key == "name" {
                        tableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_NAME")))
                        tableValues.append(AppConfigEditTableValue.valueForTextEntry(key, andValue: value as? String ?? "", numberOnly: false))
                        break;
                    }
                }
            }
            for (key, value) in configurationSettings {
                if key == "name" {
                    continue
                }
                if !configSectionAdded {
                    
                    if customizedCopy {
                        tableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_SETTINGS")))
                    } else {
                        tableValues.append(AppConfigEditTableValue.valueForSection(configName))
                    }
                    configSectionAdded = true
                }
                if modelValues != nil {
                    if modelValues![key] is Bool {
                        tableValues.append(AppConfigEditTableValue.valueForSwitchValue(key, andSwitchedOn: value as? Bool ?? false))
                        continue
                    }
                    if model?.isRawRepresentable(key) ?? false {
                        let choices: [String] = model?.getRawRepresentableValues(key) ?? []
                        tableValues.append(AppConfigEditTableValue.valueForSelection(key, andValue: value as? String ?? "", andChoices: choices))
                        continue
                    }
                    if modelValues![key] is Int {
                        tableValues.append(AppConfigEditTableValue.valueForTextEntry(key, andValue: "\(value)", numberOnly: true))
                    } else {
                        tableValues.append(AppConfigEditTableValue.valueForTextEntry(key, andValue: "\(value)", numberOnly: false))
                    }
                }
            }
        }

        //Add actions and reload table
        tableValues.append(AppConfigEditTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_EDIT_SECTION_ACTIONS")))
        if newConfig {
            tableValues.append(AppConfigEditTableValue.valueForAction(.Save, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_CREATE")))
        } else {
            tableValues.append(AppConfigEditTableValue.valueForAction(.Save, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_APPLY")))
        }
        if !newConfig {
            if !AppConfigStorage.sharedManager.isCustomConfig(configName) || AppConfigStorage.sharedManager.isConfigOverride(configName) {
                tableValues.append(AppConfigEditTableValue.valueForAction(.Revert, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_RESET")))
            } else {
                tableValues.append(AppConfigEditTableValue.valueForAction(.Revert, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_DELETE")))
            }
        }
        tableValues.append(AppConfigEditTableValue.valueForAction(.Cancel, andText: AppConfigBundle.localizedString("CFLAC_EDIT_ACTION_CANCEL")))
        table.reloadData()
    }
    

    // --
    // MARK: UITableViewDataSource
    // --
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValues.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Create cell (if needed)
        let tableValue = tableValues[indexPath.row]
        let nextType = indexPath.row + 1 < tableValues.count ? tableValues[indexPath.row + 1].type : AppConfigEditTableValueType.Unknown
        var cell: AppConfigTableCell? = tableView.dequeueReusableCellWithIdentifier(tableValue.type.rawValue) as? AppConfigTableCell
        if cell == nil {
            cell = AppConfigTableCell()
        }
        
        //Set up a loader cell
        if tableValue.type == .Loading {
            //Create view
            var cellView: AppConfigLoadingCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigLoadingCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigLoadingCellView
            }

            //Supply data
            cell?.selectionStyle = .None
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = tableValue.labelString
        }

        //Set up an action cell
        if tableValue.type == .Action {
            //Create view
            var cellView: AppConfigItemCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigItemCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigItemCellView
            }
            
            //Supply data
            cell?.selectionStyle = .Default
            cell?.accessoryType = .DisclosureIndicator
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = tableValue.labelString
        }
        
        //Set up a text entry cell
        if tableValue.type == .TextEntry {
            //Create view
            var cellView: AppConfigEditTextCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigEditTextCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigEditTextCellView
            }

            //Supply data
            cell?.selectionStyle = .Default
            cell?.shouldHideDivider = !nextType.isCellType()
            //TODO: set delegate for text updates
            cellView!.label = tableValue.configSetting
            cellView!.editedText = tableValue.labelString
            cellView!.applyNumberLimitation = tableValue.limitUsage
        }
        
        //Set up a switch value cell
        if tableValue.type == .SwitchValue {
            //Create view
            var cellView: AppConfigEditSwitchCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigEditSwitchCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigEditSwitchCellView
            }

            //Supply data
            cell?.selectionStyle = .Default
            cell?.shouldHideDivider = !nextType.isCellType()
            //TODO: set delegate for switch toggle updates
            cellView!.label = tableValue.configSetting
            cellView!.on = tableValue.booleanValue
        }
        
        //Set up a selection cell (for enums)
        if tableValue.type == .Selection {
            //Create view
            var cellView: AppConfigItemCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigItemCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigItemCellView
            }
            
            //Supply data
            cell?.selectionStyle = .Default
            cell?.accessoryType = .DisclosureIndicator
            cell?.shouldHideDivider = !nextType.isCellType()
            cellView!.label = "\(tableValue.configSetting ?? ""): \(tableValue.labelString)"
        }
        
        //Set up a section cell
        if tableValue.type == .Section {
            //Create view
            var cellView: AppConfigSectionCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigSectionCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigSectionCellView
            }
            
            //Supply data
            cell?.selectionStyle = .None
            cell?.shouldHideDivider = true
            cellView!.label = tableValue.labelString
        }
        
        //Return result
        return cell!
    }
    
    
    // --
    // MARK: UITableViewDelegate
    // --
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tableValue = tableValues[indexPath.row]
        UIApplication.sharedApplication().sendAction(#selector(resignFirstResponder), to: nil, from: nil, forEvent: nil)
        if tableValue.type == .Action && delegate != nil {
            switch tableValue.action {
            case .Save:
                delegate?.saveConfig([:])
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
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AppConfigTableCell {
                if let switchCellView = cell.cellView as? AppConfigEditSwitchCellView {
                    switchCellView.on = !switchCellView.on
                }
            }
        } else if tableValue.type == .TextEntry {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? AppConfigTableCell {
                if let editTextCellView = cell.cellView as? AppConfigEditTextCellView {
                    editTextCellView.startEditing()
                }
            }
        }
        table.deselectRowAtIndexPath(indexPath, animated: false)
    }
    

    // --
    // MARK: AppConfigSelectionPopupViewDelegate
    // --
    
    func selectedItem(item: String, token: String?) {
        //
    }
    
}
