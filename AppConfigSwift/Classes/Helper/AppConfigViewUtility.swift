//
//  AppConfigViewUtility.swift
//  AppConfigSwift Pod
//
//  Library helper: view utility
//  Provides helper functions to load nib files and set up constraints
//

open class AppConfigViewUtility {
    
    // --
    // MARK: Initialization
    // --
    
    public init() { }
    
    
    // --
    // MARK: Load NIB
    // --
    
    open static func loadNib(_ name: String, parentView: UIView) -> UIView {
        let nib = AppConfigBundle.loadNibNamed(name, owner: parentView, options: nil)
        if let contentView = nib?.instantiate(withOwner: parentView, options: nil)[0] as? UIView {
            contentView.frame = parentView.bounds
            parentView.addSubview(contentView)
            addPinSuperViewEdgesConstraints(contentView, parentView: parentView)
            return contentView
        }
        let dummyView = UIView()
        parentView.addSubview(dummyView)
        return dummyView
    }
    

    // --
    // MARK: Constraint setup
    // --
    
    open static func addPinSuperViewEdgeConstraint(_ view: UIView, parentView: UIView, edge: NSLayoutAttribute, constant: CGFloat = 0) -> NSLayoutConstraint? {
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
    
    open static func addPinSuperViewHorizontalEdgesConstraints(_ view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .left)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .right)
    }

    open static func addPinSuperViewEdgesConstraints(_ view: UIView, parentView: UIView) {
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .left)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .right)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .top)
        addPinSuperViewEdgeConstraint(view, parentView: parentView, edge: .bottom)
    }
    
    open static func addSizeAxisConstraint(_ view: UIView, axisSize: CGFloat, axis: NSLayoutAttribute) {
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

    open static func addWidthConstraint(_ view: UIView, width: CGFloat) {
        addSizeAxisConstraint(view, axisSize: width, axis: .width)
    }

    open static func addHeightConstraint(_ view: UIView, height: CGFloat) {
        addSizeAxisConstraint(view, axisSize: height, axis: .height)
    }
    
}
