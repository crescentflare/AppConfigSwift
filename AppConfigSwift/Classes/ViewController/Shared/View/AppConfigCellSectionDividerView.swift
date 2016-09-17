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
@IBDesignable open class AppConfigCellSectionDividerView : UIView {
    
    // --
    // MARK: Members
    // --
    
    fileprivate var _location: AppConfigCellSectionLocation = .None
    fileprivate var _dividerLine: UIView? = nil
    fileprivate var _dividerLineConstraint: NSLayoutConstraint? = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var dividerLocation: String = "" {
        didSet {
            location = AppConfigCellSectionLocation.init(rawValue: dividerLocation) ?? .none
        }
    }

    var location: AppConfigCellSectionLocation? {
        set {
            _location = newValue ?? .None
            if _dividerLine != nil {
                if _dividerLineConstraint != nil {
                    _dividerLine?.removeConstraint(_dividerLineConstraint!)
                }
                _dividerLineConstraint = AppConfigViewUtility.addPinSuperViewEdgeConstraint(view: _dividerLine!, parentView: self, edge: _location == .Top ? .bottom : .top)
                _dividerLine?.isHidden = _location == .None
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
        self.init(frame: CGRect.zero)
        setupDivider(location)
    }
    
    open func setupView() {
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
    }
    
    open func setupDivider(_ location: AppConfigCellSectionLocation) {
        _dividerLine = UIView()
        _dividerLine?.backgroundColor = UIColor.init(white: 0.75, alpha: 1)
        addSubview(_dividerLine!)
        AppConfigViewUtility.addPinSuperViewHorizontalEdgesConstraints(view: _dividerLine!, parentView: self)
        AppConfigViewUtility.addHeightConstraint(view: _dividerLine!, height: 1 / UIScreen.main.scale)
        self.location = location
    }
    

    // --
    // MARK: Layout
    // --

    open override var intrinsicContentSize : CGSize {
        return CGSize(width: 0, height: 8)
    }

}
