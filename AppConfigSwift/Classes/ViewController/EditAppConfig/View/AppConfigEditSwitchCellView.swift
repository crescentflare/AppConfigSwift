//
//  AppConfigEditSwitchCellView.swift
//  AppConfigSwift Pod
//
//  Library view: edit configuration
//  A cell to switch a value on or off
//

import UIKit

//Delegate protocol
protocol AppConfigEditSwitchCellViewDelegate: class {
    
    func changedSwitchState(_ on: Bool, forConfigSetting: String)
    
}

@IBDesignable open class AppConfigEditSwitchCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigEditSwitchCellViewDelegate?
    fileprivate var _contentView: UIView! = nil
    @IBOutlet fileprivate var _label: UILabel! = nil
    @IBOutlet fileprivate var _switchControl: UISwitch! = nil

    
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
            _switchControl.isOn = switchOn
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
            _switchControl!.isOn = newValue ?? false
        }
        get { return _switchControl!.isOn }
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
    
    open func setupView() {
        _contentView = AppConfigViewUtility.loadNib("EditSwitchCell", parentView: self)
        _label.text = ""
        _switchControl.addTarget(self, action: #selector(setState), for: .valueChanged)
        _switchControl.isOn = false
    }
   

    // --
    // MARK: Selector
    // --
    
    func setState(_ switchComponent: UISwitch) {
        delegate?.changedSwitchState(switchComponent.isOn, forConfigSetting: label ?? "")
    }


    // --
    // MARK: Helper
    // --
    
    open func toggleState() {
        let newState = !on
        _switchControl.setOn(newState, animated: true)
        delegate?.changedSwitchState(newState, forConfigSetting: label ?? "")
    }

}
