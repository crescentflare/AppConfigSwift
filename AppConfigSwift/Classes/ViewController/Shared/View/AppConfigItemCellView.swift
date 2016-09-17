//
//  AppConfigItemCellView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A simple cell with a label and an optional secondary label on the right
//

import UIKit

@IBDesignable class AppConfigItemCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _contentView: UIView! = nil
    @IBOutlet private var _label: UILabel! = nil
    @IBOutlet private var _additional: UILabel! = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var labelText: String = "" {
        didSet {
            label = labelText
        }
    }

    @IBInspectable var additionalText: String = "" {
        didSet {
            additional = additionalText
        }
    }

    var label: String? {
        set {
            _label!.text = newValue
        }
        get { return _label!.text }
    }

    var additional: String? {
        set {
            _additional!.text = newValue
        }
        get { return _additional!.text }
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
        _contentView = AppConfigViewUtility.loadNib(named: "ItemCell", parentView: self)
        _label.text = ""
        _additional.text = ""
    }

}
