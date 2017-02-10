//
//  AppConfigManageInfoCellView.swift
//  AppConfigSwift Pod
//
//  Library view: managing configurations
//  A small cell for displaying general build information
//

import UIKit

@IBDesignable class AppConfigManageInfoCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _contentView: UIView! = nil
    @IBOutlet private var _label: UILabel! = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var labelText: String = "" {
        didSet {
            label = labelText
        }
    }
    
    var label: String? {
        set {
            _label!.text = newValue
        }
        get { return _label!.text }
    }

    
    // --
    // MARK: Initialization
    // --
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        _contentView = AppConfigViewUtility.loadNib(named: "ManageInfoCell", parentView: self)
        _label.text = ""
    }
   
}
