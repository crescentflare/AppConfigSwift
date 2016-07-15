//
//  AppConfigBaseModel.swift
//  AppConfigSwift Pod
//
//  Library model: base model for strict typing
//  Derive your custom app configuration from this model for easy integration
//  Important: this moment, only flat models with primitive data types and custom enums are supported
//

public class AppConfigBaseModel {

    // --
    // MARK: Initialization
    // --

    //Initialization
    public init() { }
    
    
    // --
    // MARK: Model structure analysis
    // --
    
    //Provides mapping between config selectiom, editing, also provides optional categorization
    //Override in your derived model (check the example for details)
    public func map(mapper: AppConfigModelMapper) { }

    //Helper method to convert the list of defined properties in the derived model to a dictionary
    public func obtainValues() -> [String: Any] {
        let mapper: AppConfigModelMapper = AppConfigModelMapper(mode: .ToDictionary)
        map(mapper)
        return mapper.getDictionaryValues()
    }
    
    //Internal method to override the model with customized values
    public func applyOverrides(overrides: [String: Any], name: String?) {
        var setValues = overrides
        if name != nil {
            setValues["name"] = name!
        } else {
            setValues.removeValueForKey("name")
        }
        let mapper: AppConfigModelMapper = AppConfigModelMapper(dictionary: setValues, mode: .FromDictionary)
        map(mapper)
    }
 
}
