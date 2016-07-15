//
//  AppConfigItemCellView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A simple cell with a label and an optional secondary label on the right
//

import UIKit

@IBDesignable public class AppConfigItemCellView : UIView {
    
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
            _label.text = labelText
        }
    }

    @IBInspectable var additionalText: String = "" {
        didSet {
            _additional.text = additionalText
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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setupView() {
        _contentView = AppConfigViewUtility.loadNib("ItemCell", parentView: self)
        _label.text = ""
        _additional.text = ""
    }

    
    // --
    // MARK: Layout
    // --
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let result: CGSize = _contentView.systemLayoutSizeFittingSize(CGSizeMake(size.width, 0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        return CGSizeMake(size.width, result.height)
    }
    
}
