//
//  AppConfigSectionCellView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A cell with a label to be used as a table section
//

import UIKit

@IBDesignable open class AppConfigSectionCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    fileprivate var _contentView: UIView! = nil
    @IBOutlet fileprivate var _label: UILabel! = nil

    
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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    open func setupView() {
        _contentView = AppConfigViewUtility.loadNib(named: "SectionCell", parentView: self)
        _label.text = ""
    }

}
