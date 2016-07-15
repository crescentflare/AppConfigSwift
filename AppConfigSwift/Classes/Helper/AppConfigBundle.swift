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
    
    public static func imageNamed(image: String) -> UIImage? {
        return UIImage.init(named: image, inBundle: AppConfigBundle.podBundle(), compatibleWithTraitCollection: nil)
    }
    
    public static func loadNibNamed(name: String!, owner: AnyObject!, options: [NSObject: AnyObject]!) -> UINib! {
        return UINib(nibName: name, bundle: AppConfigBundle.podBundle())
    }

    public static func localizedString(key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: AppConfigBundle.podBundle()!, value: key, comment: "")
    }

    
    // --
    // MARK: Internal helper
    // --
    private static func podBundle() -> NSBundle? {
        if let url = NSBundle.init(forClass: AppConfigBundle.self).URLForResource("AppConfigSwift", withExtension: "bundle") {
            return NSBundle.init(URL: url)
        }
        return nil
    }
    
}
