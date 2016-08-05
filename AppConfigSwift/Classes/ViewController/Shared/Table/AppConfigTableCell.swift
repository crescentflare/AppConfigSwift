//
//  AppConfigTableCell.swift
//  AppConfigSwift Pod
//
//  Library table cell: shared component
//  Custom table view cell for dynamic table cells (in view and layout)
//  Used internally
//

import UIKit

public class AppConfigTableCell : UITableViewCell {
    
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
                AppConfigViewUtility.addPinSuperViewEdgesConstraints(_cellView!, parentView: contentView)
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
    
    public func setupView() {
        _dividerLine = UIView()
        _dividerLine?.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        addSubview(_dividerLine!)
        AppConfigViewUtility.addHeightConstraint(_dividerLine!, height: 1 / UIScreen.mainScreen().scale)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(_dividerLine!, parentView: self, edge: .Left, constant: 16)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(_dividerLine!, parentView: self, edge: .Right)
        AppConfigViewUtility.addPinSuperViewEdgeConstraint(_dividerLine!, parentView: self, edge: .Bottom)
    }

    
    // --
    // MARK: Layout
    // --
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _dividerLine?.hidden = shouldHideDivider
    }
    
}
