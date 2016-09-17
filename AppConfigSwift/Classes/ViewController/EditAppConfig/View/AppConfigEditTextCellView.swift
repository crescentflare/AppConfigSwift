//
//  AppConfigEditTextCellView.swift
//  AppConfigSwift Pod
//
//  Library view: edit configuration
//  A cell to edit a section by entering text or a number
//

import UIKit

//Delegate protocol
protocol AppConfigEditTextCellViewDelegate: class {
    
    func changedEditText(_ newText: String, forConfigSetting: String)
    
}

@IBDesignable open class AppConfigEditTextCellView : UIView, UITextFieldDelegate {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigEditTextCellViewDelegate?
    fileprivate var _contentView: UIView! = nil
    @IBOutlet fileprivate var _label: UILabel! = nil
    @IBOutlet fileprivate var _editedText: UITextField! = nil
    fileprivate var _applyNumberLimitation = false

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var labelText: String = "" {
        didSet {
            label = labelText
        }
    }
    
    @IBInspectable var enteredEditedText: String = "" {
        didSet {
            editedText = enteredEditedText
        }
    }

    @IBInspectable var limitedToNumbers: Bool = false {
        didSet {
            applyNumberLimitation = limitedToNumbers
        }
    }

    var label: String? {
        set {
            _label!.text = newValue
        }
        get { return _label!.text }
    }

    var editedText: String? {
        set {
            _editedText!.text = newValue
        }
        get { return _editedText!.text }
    }
    
    var applyNumberLimitation: Bool {
        set {
            _applyNumberLimitation = newValue
            _editedText.keyboardType = _applyNumberLimitation ? .numbersAndPunctuation : .alphabet
        }
        get { return _applyNumberLimitation }
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
        _contentView = AppConfigViewUtility.loadNib(named: "EditTextCell", parentView: self)
        _label.textColor = tintColor
        _label.text = ""
        _editedText.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
        _editedText.delegate = self
        _editedText.text = ""
    }

    
    // --
    // MARK: Selector
    // --
    
    func textFieldDidChange(_ textField: UITextField) {
        delegate?.changedEditText(textField.text ?? "", forConfigSetting: label ?? "")
    }
    
    
    // --
    // MARK: UITextFieldDelegate
    // --

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Only use limitation code if applied
        if !applyNumberLimitation {
            return true
        }
        
        //Allow backspace
        if string.characters.count == 0 {
            return true
        }
        
        //Prevent invalid character input, if keyboard is set to a number-like input form
        if textField.keyboardType == .numbersAndPunctuation || textField.keyboardType == .numberPad {
            var checkString = string
            if textField.text?.characters.count == 0 {
                if string.range(of: "-")?.lowerBound == string.startIndex {
                    checkString = string.substring(from: string.characters.index(string.startIndex, offsetBy: 1))
                }
            }
            if checkString.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                return false
            }
        }
        return true
    }
    
    
    // --
    // MARK: Helpers
    // --
   
    open func startEditing() {
        _editedText.becomeFirstResponder()
    }
    
}
