//
//  AppConfigTableCell.swift
//  AppConfigSwift Pod
//
//  Library table cell: shared component
//  Custom table view cell for dynamic table cells (in view and layout)
//  Used internally
//

import UIKit

open class AppConfigTableCell : UITableViewCell {
    
    // --
    // MARK: Members
    // --
    
    var shouldHideDivider: Bool = false
    var _dividerLine: UIView? = nil
    var _cellView: UIView? = nil
    var cellView: UIView? {
        set {
            if _cellView != nil {
                _cellView!.removeFromSuperview()
            }
            _cellView = newValue
            if _cellView != nil {
                contentView.addSubview(_cellView!)
                AppConfigViewUtility.addPinSuperViewEdgesConstraints(view: _cellView!, parentView: contentView)
            }
        }
        get { return _cellView }
    }

    
    // --
    // MARK: Initialize
    // --

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    open func setupView() {
        _dividerLine = UIView()
        _dividerLine?.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        addSubview(_dividerLine!)
        AppConfigViewUtility.addHeightConstraint(view: _dividerLine!, height: 1 / UIScreen.main.scale)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(view: _dividerLine!, parentView: self, edge: .left, constant: 16)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(view: _dividerLine!, parentView: self, edge: .right)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(view: _dividerLine!, parentView: self, edge: .bottom)
    }

    
    // --
    // MARK: Layout
    // --
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _dividerLine?.isHidden = shouldHideDivider
    }
    
}
