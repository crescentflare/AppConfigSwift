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
    
    public static func loadNib(named: String, parentView: UIView) -> UIView {
        let nib = AppConfigBundle.loadNib(named: named, owner: parentView, options: nil)
        if let contentView = nib?.instantiate(withOwner: parentView, options: nil)[0] as? UIView {
            contentView.frame = parentView.bounds
            parentView.addSubview(contentView)
            addPinSuperViewEdgesConstraints(view: contentView, parentView: parentView)
            return contentView
        }
        let dummyView = UIView()
        parentView.addSubview(dummyView)
        return dummyView
    }
    

    // --
    // MARK: Constraint setup
    // --
    
    public static func addPinSuperViewEdgeConstraint(view: UIView, parentView: UIView, edge: NSLayoutAttribute, constant: CGFloat = 0) -> NSLayoutConstraint? {
        if edge == .left || edge == .right || edge == .top || edge == .bottom {
            let constraint = NSLayoutConstraint(item: view,
                                                attribute: edge,
                                                relatedBy: .equal,
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
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .left)
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .right)
    }

    public static func addPinSuperViewEdgesConstraints(view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .left)
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .right)
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .top)
        addPinSuperViewEdgeConstraint(view: view, parentView: parentView, edge: .bottom)
    }
    
    public static func addSizeAxisConstraint(view: UIView, axisSize: CGFloat, axis: NSLayoutAttribute) {
        if axis == .width || axis == .height {
            let constraint = NSLayoutConstraint(item: view,
                                                attribute: axis,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: axis,
                                                multiplier: 1.0,
                                                constant: axisSize)
            view.addConstraint(constraint)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    public static func addWidthConstraint(view: UIView, width: CGFloat) {
        addSizeAxisConstraint(view: view, axisSize: width, axis: .width)
    }

    public static func addHeightConstraint(view: UIView, height: CGFloat) {
        addSizeAxisConstraint(view: view, axisSize: height, axis: .height)
    }
    
}
