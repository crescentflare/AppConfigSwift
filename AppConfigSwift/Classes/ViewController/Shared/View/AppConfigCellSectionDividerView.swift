//
//  AppConfigCellSectionDividerView.swift
//  AppConfigSwift Pod
//
//  Library view: shared component
//  A divider view between cell sections (to make them stand out more)
//

import UIKit

// Value type enum
enum AppConfigCellSectionLocation: String {
    
    case none = "none"
    case top = "top"
    case bottom = "bottom"
    
}

// View component
@IBDesignable class AppConfigCellSectionDividerView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _location = AppConfigCellSectionLocation.none
    private var _dividerLine: UIView? = nil
    private var _dividerLineConstraint: NSLayoutConstraint? = nil

    
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
            _location = newValue ?? .none
            if _dividerLine != nil {
                if _dividerLineConstraint != nil {
                    _dividerLine?.removeConstraint(_dividerLineConstraint!)
                }
                _dividerLineConstraint = AppConfigViewUtility.addPinSuperViewEdgeConstraint(view: _dividerLine!, parentView: self, edge: _location == .top ? .bottom : .top)
                _dividerLine?.isHidden = _location == .none
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    convenience init(location: AppConfigCellSectionLocation) {
        self.init(frame: CGRect.zero)
        setupDivider(location: location)
    }
    
    func setupView() {
        self.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
    }
    
    func setupDivider(location: AppConfigCellSectionLocation) {
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

    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0, height: 8)
    }

}
