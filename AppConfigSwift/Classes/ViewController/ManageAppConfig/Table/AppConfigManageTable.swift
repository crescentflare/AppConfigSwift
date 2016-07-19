//
//  AppConfigManageTable.swift
//  AppConfigSwift Pod
//
//  Library table: managing configurations
//  The table view and data source for the manage config viewcontroller
//  Used internally
//

import UIKit

//Delegate protocol
protocol AppConfigManageTableDelegate: class {

    func selectedConfig(configName: String)
    func editConfig(configName: String)
    func newCustomConfigFrom(configName: String)

}


//Class
public class AppConfigManageTable : UIView, UITableViewDataSource, UITableViewDelegate, AppConfigSelectionPopupViewDelegate {
    
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
        tableValues.append(AppConfigManageTableValue.valueForLoading(AppConfigBundle.localizedString("CFLAC_SHARED_LOADING_CONFIGS")))
    }

    
    // --
    // MARK: Implementation
    // --
    
    public func setConfigurations(configurations: [String], customConfigurations: [String], lastSelected: String?) {
        //Start with an empty table values list
        tableValues = []
        
        //Add predefined configurations (if present)
        if configurations.count > 0 {
            tableValues.append(AppConfigManageTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_MANAGE_SECTION_PREDEFINED")))
            for configuration: String in configurations {
                tableValues.append(AppConfigManageTableValue.valueForConfig(configuration, andText: configuration, lastSelected: configuration == lastSelected, edited: AppConfigStorage.sharedManager.isConfigOverride(configuration)))
            }
        }
        
        //Add custom configurations (if present)
        if configurations.count > 0 {
            tableValues.append(AppConfigManageTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_MANAGE_SECTION_CUSTOM")))
            for configuration: String in customConfigurations {
                tableValues.append(AppConfigManageTableValue.valueForConfig(configuration, andText: configuration, lastSelected: configuration == lastSelected, edited: false))
            }
            tableValues.append(AppConfigManageTableValue.valueForConfig(nil, andText: AppConfigBundle.localizedString("CFLAC_MANAGE_ADD_NEW"), lastSelected: false, edited: false))
        }
        
        //Add build information
        let bundleVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        tableValues.append(AppConfigManageTableValue.valueForSection(AppConfigBundle.localizedString("CFLAC_MANAGE_SECTION_BUILD_INFO")))
        tableValues.append(AppConfigManageTableValue.valueForInfo(AppConfigBundle.localizedString("CFLAC_MANAGE_BUILD_NR") + ": " + bundleVersion))
        tableValues.append(AppConfigManageTableValue.valueForInfo(AppConfigBundle.localizedString("CFLAC_MANAGE_BUILD_IOS_VERSION") + ": " + UIDevice.currentDevice().systemVersion))
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
        let nextType = indexPath.row + 1 < tableValues.count ? tableValues[indexPath.row + 1].type : AppConfigManageTableValueType.Unknown
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
            cell?.shouldHideDivider = nextType != .Config && nextType != .Info && nextType != .Loading
            cellView!.label = tableValue.labelString
        }
        
        //Set up a config cell
        if tableValue.type == .Config {
            //Create view
            var cellView: AppConfigItemCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigItemCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigItemCellView
            }
            
            //Supply data
            cell?.accessoryType = tableValue.lastSelected ? .Checkmark : .DisclosureIndicator
            cell?.shouldHideDivider = nextType != .Config && nextType != .Info && nextType != .Loading
            cellView!.label = tableValue.labelString
            if tableValue.edited {
                cellView!.additional = AppConfigBundle.localizedString("CFLAC_MANAGE_INDICATOR_EDITED")
            }
        }
        
        //Set up an info cell
        if tableValue.type == .Info {
            //Create view
            var cellView: AppConfigManageInfoCellView? = nil
            if cell!.cellView == nil {
                cellView = AppConfigManageInfoCellView()
                cell!.cellView = cellView
            } else {
                cellView = cell!.cellView as? AppConfigManageInfoCellView
            }
            
            //Supply data
            cell?.selectionStyle = .None
            cell?.shouldHideDivider = nextType != .Config && nextType != .Info && nextType != .Loading
            cellView!.label = tableValue.labelString
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
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let tableValue = tableValues[indexPath.row]
        return tableValue.type == .Config
    }
    
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction.init(style: .Normal, title: AppConfigBundle.localizedString("CFLAC_MANAGE_SWIPE_EDIT"), handler: { action, indexPath in
            let tableValue = self.tableValues[indexPath.row]
            tableView.setEditing(false, animated: true)
            if tableValue.config != nil {
                self.delegate?.editConfig(tableValue.config!)
            }
        })
        editAction.backgroundColor = UIColor.blueColor()
        return [editAction]
    }
    
    
    // --
    // MARK: UITableViewDelegate
    // --
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tableValue = tableValues[indexPath.row]
        if delegate != nil {
            if tableValue.config != nil {
                delegate?.selectedConfig(tableValue.config!)
            } else if tableValue.type == .Config {
                let choicePopup = AppConfigSelectionPopupView()
                choicePopup.label = AppConfigBundle.localizedString("CFLAC_SHARED_SELECT_MENU")
                choicePopup.choices = AppConfigStorage.sharedManager.obtainConfigList()
                choicePopup.delegate = self
                choicePopup.addToSuperview(self)
                AppConfigViewUtility.addPinSuperViewEdgesConstraints(choicePopup, parentView: self)
            }
        }
        table.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    // --
    // MARK: AppConfigSelectionPopupViewDelegate
    // --
    
    func selectedItem(item: String, token: String?) {
        delegate?.newCustomConfigFrom(item)
    }

}
