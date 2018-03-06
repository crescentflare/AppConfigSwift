//
//  ShowLogViewController.swift
//  AppConfigSwift Example
//
//  Scrolls through the log
//

import UIKit
import AppConfigSwift

class ShowLogViewController: UIViewController {

    // --
    // MARK: View components
    // --
    
    @IBOutlet weak var logText: UILabel!
    
    
    // --
    // MARK: Lifecycle
    // --
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logText.text = Logger.logString()
    }
    
}
