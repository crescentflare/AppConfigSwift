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
            let doneButton: UIButton = UIButton()
            doneButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            doneButton.setTitle(AppConfigBundle.localizedString("CFLAC_SHARED_DONE"), forState: UIControlState.Normal)
            doneButton.setTitleColor(tintColor, forState: UIControlState.Normal)
            doneButton.setTitleColor(highlightColor, forState: UIControlState.Highlighted)
            let size: CGSize = doneButton.sizeThatFits(CGSizeZero)
            doneButton.frame = CGRectMake(0, 0, size.width, size.height)
            doneButton.addTarget(self, action: #selector(doneButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
            
            //Wrap in bar button item
            let doneButtonWrapper: UIBarButtonItem = UIBarButtonItem.init(customView: doneButton)
            navigationItem.leftBarButtonItem = doneButtonWrapper
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
    
    public override func viewDidAppear(animated: Bool) {
        if isLoaded {
            self.manageConfigTable.setConfigurations(AppConfigStorage.sharedManager.obtainConfigList(), lastSelected: AppConfigStorage.sharedManager.selectedConfig())
        }
    }
    
    
    // --
    // MARK: Selectors
    // --
    
    func doneButtonPressed(sender: UIButton) {
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
        if isLoaded {
            self.manageConfigTable.setConfigurations(AppConfigStorage.sharedManager.obtainConfigList(), lastSelected: AppConfigStorage.sharedManager.selectedConfig())
        }
    }
    
    func editConfig(configName: String) {
        let viewController = AppConfigEditViewController(configName: configName, newConfig: false)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
