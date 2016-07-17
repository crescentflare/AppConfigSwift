//
//  AppConfigEditTextCellView.swift
//  AppConfigSwift Pod
//
//  Library view: edit configuration
//  A cell to edit a section by entering text or a number
//

import UIKit

@IBDesignable public class AppConfigEditTextCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
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
        _editedText.text = ""
    }

    
    // --
    // MARK: Helpers
    // --
   
    public func startEditing() {
        _editedText.becomeFirstResponder()
    }
    
}
