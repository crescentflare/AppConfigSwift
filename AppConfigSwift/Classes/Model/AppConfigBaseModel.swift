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
        let mapper = AppConfigModelMapper(mode: .ToDictionary)
        map(mapper)
        return mapper.getDictionaryValues()
    }
    
    public func obtainCategorizedFields() -> AppConfigOrderedDictionary<String, [String]> {
        let mapper = AppConfigModelMapper(mode: .CollectKeys)
        map(mapper)
        return mapper.getCategorizedFields()
    }
    
    //Helper method to determine if the value is a raw representable (like an enum)
    public func isRawRepresentable(fieldName: String) -> Bool {
        let mapper = AppConfigModelMapper(mode: .CollectKeys)
        map(mapper)
        return mapper.isRawRepresentable(fieldName)
    }
    
    public func getRawRepresentableValues(fieldName: String) -> [String]? {
        let mapper = AppConfigModelMapper(mode: .CollectKeys)
        map(mapper)
        return mapper.getRawRepresentableValues(fieldName)
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
