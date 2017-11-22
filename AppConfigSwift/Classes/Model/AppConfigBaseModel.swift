//
//  AppConfigBaseModel.swift
//  AppConfigSwift Pod
//
//  Library model: base model for strict typing
//  Derive your custom app configuration from this model for easy integration
//  Important: this moment, only flat models with primitive data types and custom enums are supported
//

open class AppConfigBaseModel {

    // --
    // MARK: Initialization
    // --

    // Initialization
    public init() { }
    
    
    // --
    // MARK: Model structure analysis
    // --
    
    // Provides mapping between config selectiom, editing, also provides optional categorization
    // Override in your derived model (check the example for details)
    open func map(mapper: AppConfigModelMapper) { }

    // Helper method to convert the list of defined properties in the derived model to a dictionary
    public func obtainValues() -> [String: Any] {
        let mapper = AppConfigModelMapper(mode: .toDictionary)
        map(mapper: mapper)
        return mapper.getDictionaryValues()
    }
    
    // Helper method to obtain all fields in a dictionary grouped by categories
    public func obtainCategorizedFields() -> AppConfigOrderedDictionary<String, [String]> {
        let mapper = AppConfigModelMapper(mode: .collectKeys)
        map(mapper: mapper)
        return mapper.getCategorizedFields()
    }
    
    // Helper method to determine if the value is a raw representable (like an enum)
    public func isRawRepresentable(field: String) -> Bool {
        let mapper = AppConfigModelMapper(mode: .collectKeys)
        map(mapper: mapper)
        return mapper.isRawRepresentable(field: field)
    }
    
    // Helper method to obtain all values of a raw representable for the given field
    public func getRawRepresentableValues(forField: String) -> [String]? {
        let mapper = AppConfigModelMapper(mode: .collectKeys)
        map(mapper: mapper)
        return mapper.getRawRepresentableValues(forField: forField)
    }
    
    // Internal method to override the model with customized values
    public func apply(overrides: [String: Any], globalOverrides: [String: Any], name: String?) {
        var setValues = overrides
        if name != nil {
            setValues["name"] = name!
        } else {
            setValues.removeValue(forKey: "name")
        }
        let mapper = AppConfigModelMapper(dictionary: setValues, globalDictionary: globalOverrides, mode: .fromDictionary)
        map(mapper: mapper)
    }
 
}
