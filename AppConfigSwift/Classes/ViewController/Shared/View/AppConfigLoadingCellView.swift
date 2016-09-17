//
//  AppConfigLoadingCellView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A cell to be used as a loading indicator, contains text and a spinner
//

import UIKit

@IBDesignable open class AppConfigLoadingCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    fileprivate var _contentView: UIView! = nil
    @IBOutlet fileprivate var _label: UILabel! = nil
    @IBOutlet fileprivate var _spinner: UIActivityIndicatorView! = nil

    
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
        _contentView = AppConfigViewUtility.loadNib(named: "LoadingCell", parentView: self)
        _label.text = ""
        _spinner.startAnimating()
    }

}
