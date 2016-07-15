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
    // MARK: Layout
    // --
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if shouldHideDivider {
            self.separatorInset = UIEdgeInsetsMake(0, frame.size.width * 2, 0, 0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0)
        }
    }
    
}
