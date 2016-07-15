//
//  AppConfigViewUtility.swift
//  AppConfigSwift Pod
//
//  Library helper: view utility
//  Provides helper functions to load nib files and set up constraints
//

public class AppConfigViewUtility {
    
    // --
    // MARK: Initialization
    // --
    
    public init() { }
    
    
    // --
    // MARK: Implementation
    // --
    
    public static func loadNib(name: String, parentView: UIView) -> UIView {
        let nib = AppConfigBundle.loadNibNamed(name, owner: parentView, options: nil)
        let contentView = nib.instantiateWithOwner(parentView, options: nil)[0] as! UIView
        contentView.frame = parentView.bounds
        parentView.addSubview(contentView)
        addPinSuperViewEdgesConstraints(contentView, parentView: parentView)
        return contentView
    }
    
    public static func addPinSuperViewEdgeConstraint(view: UIView, parentView: UIView, edge: NSLayoutAttribute) {
        if edge == .Left || edge == .Right || edge == .Top || edge == .Bottom {
            let constraint = NSLayoutConstraint(item: view,
                                                attribute: edge,
                                                relatedBy: .Equal,
                                                toItem: parentView,
                                                attribute: edge,
                                                multiplier: 1.0,
                                                constant: 0.0)
            parentView.addConstraint(constraint)
        }
    }
    
    public static func addPinSuperViewEdgesConstraints(view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Left)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Right)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Top)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Bottom)
    }
    
}
