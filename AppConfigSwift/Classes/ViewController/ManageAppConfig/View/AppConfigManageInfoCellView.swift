//
//  AppConfigManageInfoCellView.swift
//  AppConfigSwift Pod
//
//  Library view: managing configurations
//  A small cell for displaying general build information
//

import UIKit

@IBDesignable public class AppConfigManageInfoCellView : UIView {
    
    // --
    // MARK: Members
    // --
    
    private var _contentView: UIView! = nil
    @IBOutlet private var _label: UILabel! = nil

    
    // --
    // MARK: Properties which can be used in interface builder
    // --
    
    @IBInspectable var labelText: String = "" {
        didSet {
            _label.text = labelText
        }
    }
    
    var label: String? {
        set {
            _label!.text = newValue
        }
        get { return _label!.text }
    }

    
    // --
    // MARK: Initialization
    // --
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }
    
    public func loadFromNib() {
        //Inflate nib
        let nib = AppConfigBundle.loadNibNamed("ManageInfoCell", owner: self, options: nil)
        _contentView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        _contentView.frame = bounds
        _contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
        self.addSubview(_contentView)
        
        //Empty state
        _label.text = ""
    }

    
    // --
    // MARK: Layout
    // --
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        let result: CGSize = _contentView.systemLayoutSizeFittingSize(CGSizeMake(size.width, 0), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        return CGSizeMake(size.width, result.height)
    }
   
}
