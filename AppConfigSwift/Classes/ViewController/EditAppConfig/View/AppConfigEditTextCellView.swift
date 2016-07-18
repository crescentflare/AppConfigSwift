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
    
    func changedEditText(newText: String, forConfigSetting: String)
    
}

@IBDesignable public class AppConfigEditTextCellView : UIView, UITextFieldDelegate {
    
    // --
    // MARK: Members
    // --
    
    weak var delegate: AppConfigEditTextCellViewDelegate?
    private var _contentView: UIView! = nil
    @IBOutlet private var _label: UILabel! = nil
    @IBOutlet private var _editedText: UITextField! = nil
    private var _applyNumberLimitation = false

    
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
            _editedText.keyboardType = _applyNumberLimitation ? .NumbersAndPunctuation : .Alphabet
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
    
    public func setupView() {
        _contentView = AppConfigViewUtility.loadNib("EditTextCell", parentView: self)
        _label.textColor = tintColor
        _label.text = ""
        _editedText.addTarget(self, action: #selector(textFieldDidChange), forControlEvents: .AllEvents)
        _editedText.delegate = self
        _editedText.text = ""
    }

    
    // --
    // MARK: Selector
    // --
    
    func textFieldDidChange(textField: UITextField) {
        delegate?.changedEditText(textField.text ?? "", forConfigSetting: label ?? "")
    }
    
    
    // --
    // MARK: UITextFieldDelegate
    // --

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //Only use limitation code if applied
        if !applyNumberLimitation {
            return true
        }
        
        //Allow backspace
        if string.characters.count == 0 {
            return true
        }
        
        //Prevent invalid character input, if keyboard is set to a number-like input form
        if textField.keyboardType == .NumbersAndPunctuation || textField.keyboardType == .NumberPad {
            var checkString = string
            if textField.text?.characters.count == 0 {
                if string.rangeOfString("-")?.startIndex == string.startIndex {
                    checkString = string.substringFromIndex(string.startIndex.advancedBy(1))
                }
            }
            if checkString.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) != nil {
                return false
            }
        }
        return true
    }
    
    
    // --
    // MARK: Helpers
    // --
   
    public func startEditing() {
        _editedText.becomeFirstResponder()
    }
    
}
