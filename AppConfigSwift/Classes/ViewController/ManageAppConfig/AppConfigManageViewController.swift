//
//  AppConfigManageViewController.swift
//  AppConfigSwift Pod
//
//  Library view controller: edit configuration
//  Be able to select, add and edit app configurations
//

import UIKit

public class AppConfigManageViewController : UIViewController, AppConfigManageTableDelegate {
    
    // --
    // MARK: Members
    // --
    
    var isPresentedController: Bool = false
    var isLoaded: Bool = false
    var manageConfigTable: AppConfigManageTable = AppConfigManageTable()

    
    // --
    // MARK: Lifecycle
    // --
    
    public override func viewDidLoad() {
        //Set title
        super.viewDidLoad()
        navigationItem.title = AppConfigBundle.localizedString("CFLAC_MANAGE_TITLE")
        navigationController?.navigationBar.translucent = false
        
        //Add button to close the configuration selection
        if navigationController != nil {
            //Obtain colors
            let tintColor = view.tintColor
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let highlightColor: UIColor = UIColor.init(red: red, green: green, blue: blue, alpha: 0.25)
            
            //Create button
            var cancelButton: UIButton = UIButton()
            cancelButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            cancelButton.setTitle(AppConfigBundle.localizedString("CFLAC_SHARED_CANCEL"), forState: UIControlState.Normal)
            cancelButton.setTitleColor(tintColor, forState: UIControlState.Normal)
            cancelButton.setTitleColor(highlightColor, forState: UIControlState.Highlighted)
            let size: CGSize = cancelButton.sizeThatFits(CGSizeZero)
            cancelButton.frame = CGRectMake(0, 0, size.width, size.height)
            cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            //Wrap in bar button item
            var cancelButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: cancelButton)
            navigationItem.leftBarButtonItem = cancelButtonWrapper
        }
        
        //Update configuration list
        AppConfigStorage.sharedManager.loadFromSource({
            self.isLoaded = true
            self.manageConfigTable.setConfigurations(AppConfigStorage.sharedManager.obtainConfigList(), lastSelected: AppConfigStorage.sharedManager.selectedConfig())
        })
    }
    
    public override func loadView() {
        if navigationController != nil {
            isPresentedController = navigationController!.isBeingPresented()
        } else {
            isPresentedController = isBeingPresented()
        }
        manageConfigTable.delegate = self
        view = manageConfigTable
    }
    
    
    // --
    // MARK: Selectors
    // --
    
    func cancelButtonPressed(sender: UIButton) {
        if isPresentedController {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    

    // --
    // MARK: CFLAppConfigManageTableDelegate
    // --
    
    func selectedConfig(configName: String) {
        AppConfigStorage.sharedManager.selectConfig(configName)
        if isPresentedController {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
}
