//
//  AppConfigEditSwitchCellView.swift
//  AppConfigSwift Pod
//
//  Library view: edit configuration
//  A cell to switch a value on or off
//

import UIKit

@IBDesignable public class AppConfigEditSwitchCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _contentView: UIView! = nil
    @IBOutlet private var _label: UILabel! = nil
    @IBOutlet private var _switchControl: UISwitch! = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var labelText: String = "" {
        didSet {
            _label.text = labelText
        }
    }
    
    @IBInspectable var switchOn: Bool = false {
        didSet {
            _switchControl.on = switchOn
        }
    }

    var label: String? {
        set {
            _label!.text = newValue
        }
        get { return _label!.text }
    }

    var on: Bool {
        set {
            _switchControl!.on = newValue ?? false
        }
        get { return _switchControl!.on }
    }

    
    // --
    // MARK: Initialization
    // --
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setupView() {
        _contentView = AppConfigViewUtility.loadNib("EditSwitchCell", parentView: self)
        _label.text = ""
        _switchControl.on = false
    }
   
}
