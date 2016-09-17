//
//  AppConfigBundle.swift
//  AppConfigSwift Pod
//
//  Library helper: bundle access utility
//  Provides helper functions to acquire resources from the Pod bundle (like images and strings)
//

open class AppConfigBundle {
    
    // --
    // MARK: Initialization
    // --
    
    public init() { }
    
    
    // --
    // MARK: Implementation
    // --
    
    open static func imageNamed(_ image: String) -> UIImage? {
        return UIImage.init(named: image, in: AppConfigBundle.podBundle(), compatibleWith: nil)
    }
    
    open static func loadNibNamed(_ name: String!, owner: AnyObject!, options: [AnyHashable: Any]!) -> UINib! {
        return UINib(nibName: name, bundle: AppConfigBundle.podBundle())
    }

    open static func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: AppConfigBundle.podBundle()!, value: key, comment: "")
    }

    
    // --
    // MARK: Internal helper
    // --
    fileprivate static func podBundle() -> Bundle? {
        if let url = Bundle.init(for: AppConfigBundle.self).url(forResource: "AppConfigSwift", withExtension: "bundle") {
            return Bundle.init(url: url)
        }
        return nil
    }
    
}
