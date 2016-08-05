//
//  AppConfigCellSectionDividerView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A divider view between cell sections (to make them stand out more)
//

import UIKit

// Value type enum
public enum AppConfigCellSectionLocation: String {
    
    case None = "none"
    case Top = "top"
    case Bottom = "bottom"
    
}

// View
@IBDesignable public class AppConfigCellSectionDividerView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _location: AppConfigCellSectionLocation = .None
    private var _dividerLine: UIView? = nil
    private var _dividerLineConstraint: NSLayoutConstraint? = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var dividerLocation: String = "" {
        didSet {
            location = AppConfigCellSectionLocation.init(rawValue: dividerLocation) ?? .None
        }
    }

    var location: AppConfigCellSectionLocation? {
        set {
            _location = newValue ?? .None
            if _dividerLine != nil {
                if _dividerLineConstraint != nil {
                    _dividerLine?.removeConstraint(_dividerLineConstraint!)
                }
                _dividerLineConstraint = AppConfigViewUtility.addPinSuperViewEdgeConstraint(_dividerLine!, parentView: self, edge: _location == .Top ? .Bottom : .Top)
                _dividerLine?.hidden = _location == .None
            }
        }
        get { return _location }
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

    convenience init(location: AppConfigCellSectionLocation) {
        self.init(frame: CGRectZero)
        setupDivider(location)
    }
    
    public func setupView() {
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
    }
    
    public func setupDivider(location: AppConfigCellSectionLocation) {
        _dividerLine = UIView()
        _dividerLine?.backgroundColor = UIColor.init(white: 0.75, alpha: 1)
        addSubview(_dividerLine!)
        AppConfigViewUtility.addPinSuperViewHorizontalEdgesConstraints(_dividerLine!, parentView: self)
        AppConfigViewUtility.addHeightConstraint(_dividerLine!, height: 1 / UIScreen.mainScreen().scale)
        self.location = location
    }
    

    // --
    // MARK: Layout
    // --

    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 8)
    }

}
