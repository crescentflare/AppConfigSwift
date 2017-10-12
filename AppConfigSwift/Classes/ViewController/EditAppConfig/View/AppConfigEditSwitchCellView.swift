//
//  AppConfigEditSwitchCellView.swift
//  AppConfigSwift Pod
//
//  Library view: edit configuration
//  A cell to switch a value on or off
//

import UIKit

// Delegate protocol
protocol AppConfigEditSwitchCellViewDelegate: class {
    
    func changedSwitchState(_ on: Bool, forConfigSetting: String)
    
}

// View component
@IBDesignable class AppConfigEditSwitchCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigEditSwitchCellViewDelegate?
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
            _switchControl!.isOn = newValue
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        _contentView = AppConfigViewUtility.loadNib(named: "EditSwitchCell", parentView: self)
        _label.text = ""
        _switchControl.addTarget(self, action: #selector(setState), for: .valueChanged)
        _switchControl.isOn = false
    }
   

    // --
    // MARK: Selector
    // --
    
    @objc func setState(_ switchComponent: UISwitch) {
        delegate?.changedSwitchState(switchComponent.isOn, forConfigSetting: label ?? "")
    }


    // --
    // MARK: Helper
    // --
    
    func toggleState() {
        let newState = !on
        _switchControl.setOn(newState, animated: true)
        delegate?.changedSwitchState(newState, forConfigSetting: label ?? "")
    }

}
