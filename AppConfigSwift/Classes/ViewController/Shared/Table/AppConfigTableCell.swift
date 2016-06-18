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
            }
        }
        get { return _cellView }
    }

    
    // --
    // MARK: Layout
    // --
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        if _cellView != nil {
            return _cellView!.sizeThatFits(size)
        }
        return CGSize.zero
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if shouldHideDivider {
            self.separatorInset = UIEdgeInsetsMake(0, frame.size.width * 2, 0, 0);
        }
        if _cellView != nil {
            self._cellView!.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height);
        }
    }
    
}
