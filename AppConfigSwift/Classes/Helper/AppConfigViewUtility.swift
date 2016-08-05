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
    // MARK: Load NIB
    // --
    
    public static func loadNib(name: String, parentView: UIView) -> UIView {
        let nib = AppConfigBundle.loadNibNamed(name, owner: parentView, options: nil)
        let contentView = nib.instantiateWithOwner(parentView, options: nil)[0] as! UIView
        contentView.frame = parentView.bounds
        parentView.addSubview(contentView)
        addPinSuperViewEdgesConstraints(contentView, parentView: parentView)
        return contentView
    }
    

    // --
    // MARK: Constraint setup
    // --
    
    public static func addPinSuperViewEdgeConstraint(view: UIView, parentView: UIView, edge: NSLayoutAttribute, constant: CGFloat = 0) -> NSLayoutConstraint? {
        if edge == .Left || edge == .Right || edge == .Top || edge == .Bottom {
            let constraint = NSLayoutConstraint(item: view,
                                                attribute: edge,
                                                relatedBy: .Equal,
                                                toItem: parentView,
                                                attribute: edge,
                                                multiplier: 1.0,
                                                constant: constant)
            parentView.addConstraint(constraint)
            view.translatesAutoresizingMaskIntoConstraints = false
            return constraint
        }
        return nil
    }
    
    public static func addPinSuperViewHorizontalEdgesConstraints(view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Left)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Right)
    }

    public static func addPinSuperViewEdgesConstraints(view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Left)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Right)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Top)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .Bottom)
    }
    
    public static func addSizeAxisConstraint(view: UIView, axisSize: CGFloat, axis: NSLayoutAttribute) {
        if axis == .Width || axis == .Height {
            let constraint = NSLayoutConstraint(item: view,
                                                attribute: axis,
                                                relatedBy: .Equal,
                                                toItem: nil,
                                                attribute: axis,
                                                multiplier: 1.0,
                                                constant: axisSize)
            view.addConstraint(constraint)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    public static func addWidthConstraint(view: UIView, width: CGFloat) {
        addSizeAxisConstraint(view, axisSize: width, axis: .Width)
    }

    public static func addHeightConstraint(view: UIView, height: CGFloat) {
        addSizeAxisConstraint(view, axisSize: height, axis: .Height)
    }
    
}
