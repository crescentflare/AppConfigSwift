//
//  AppConfigBundle.swift
//  AppConfigSwift Pod
//
//  Library helper: bundle access utility
//  Provides helper functions to acquire resources from the Pod bundle (like images and strings)
//

public class AppConfigBundle {
    
    // --
    // MARK: Initialization
    // --
    
    public init() { }
    
    
    // --
    // MARK: Implementation
    // --
    
    public static func image(named: String) -> UIImage? {
        return UIImage.init(named: named, in: AppConfigBundle.podBundle(), compatibleWith: nil)
    }
    
    public static func loadNib(named: String!, owner: AnyObject!, options: [AnyHashable: Any]!) -> UINib! {
        return UINib(nibName: named, bundle: AppConfigBundle.podBundle())
    }

    public static func localizedString(key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: AppConfigBundle.podBundle()!, value: key, comment: "")
    }

    
    // --
    // MARK: Internal helper
    // --
    private static func podBundle() -> Bundle? {
        if let url = Bundle.init(for: AppConfigBundle.self).url(forResource: "AppConfigSwift", withExtension: "bundle") {
            return Bundle.init(url: url)
        }
        return nil
    }
    
}
