//
//  AppConfigModelMapper.swift
//  AppConfigSwift Pod
//
//  Library model: mapping between dictionary and model
//  Used to map values dynamically between the custom model and internally stored dictionaries (for overriding settings)
//  Also provides optional categorization
//

//Enum for mapping mode
public enum AppConfigModelMapperMode {
    
    case CollectKeys
    case ToDictionary
    case FromDictionary
    
}

//Mapping class
public class AppConfigModelMapper {

    // --
    // MARK: Members
    // --

    var categorizedFields: [String: [String]] = [:]
    var dictionary: [String: Any] = [:]
    var mode: AppConfigModelMapperMode

    
    // --
    // MARK: Initialization
    // --
    
    //Initialization (for everything except FromDictionary mode)
    public init(mode: AppConfigModelMapperMode) {
        self.mode = mode
    }

    //Initialization (to be used with FromDictionary mode)
    public init(dictionary: [String: Any], mode: AppConfigModelMapperMode) {
        self.dictionary = dictionary
        self.mode = mode
    }
    
    
    // --
    // MARK: Mapping
    // --
    
    //Map between key and value: boolean
    public func map(key: String, inout value: Bool, category: String = "") {
        if mode == .ToDictionary {
            dictionary[key] = value
        } else if mode == .FromDictionary && dictionary[key] != nil {
            value = dictionary[key] as! Bool
        } else if mode == .CollectKeys {
            addKey(key, category: category)
        }
    }

    //Map between key and value: int
    public func map(key: String, inout value: Int, category: String = "") {
        if mode == .ToDictionary {
            dictionary[key] = value
        } else if mode == .FromDictionary && dictionary[key] != nil {
            value = dictionary[key] as! Int
        } else if mode == .CollectKeys {
            addKey(key, category: category)
        }
    }

    //Map between key and value: string
    public func map(key: String, inout value: String, category: String = "") {
        if mode == .ToDictionary {
            dictionary[key] = value
        } else if mode == .FromDictionary && dictionary[key] != nil {
            value = dictionary[key] as! String
        } else if mode == .CollectKeys {
            addKey(key, category: category)
        }
    }
    
    //Map between key and value: an enum containing a raw value (preferably string)
    public func map<T: RawRepresentable>(key: String, inout value: T, fallback: T, category: String = "") {
        if mode == .ToDictionary {
            dictionary[key] = value.rawValue as! Any
        } else if mode == .FromDictionary && dictionary[key] != nil {
            if let raw = dictionary[key] as? T.RawValue {
                value = T(rawValue: raw)!
            } else {
                value = fallback
            }
        } else if mode == .CollectKeys {
            addKey(key, category: category)
        }
    }
    
    //After calling mapping on the model with to dictionary mode, retrieve the result using this function
    public func getDictionaryValues() -> [String: Any] {
        return dictionary
    }

    
    // --
    // MARK: Field grouping
    // --

    //After calling mapping on the model with this object, retrieve the grouped/categorized fields
    public func getCategorizedFields() -> [String: [String]] {
        return categorizedFields
    }
    
    //Internal method to keep track of keys and categories
    private func addKey(key: String, category: String) {
        if categorizedFields[category] == nil {
            categorizedFields[category] = []
        }
        categorizedFields[category]!.append(key)
    }
    
}
