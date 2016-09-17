//
//  ExampleAppConfigModel.swift
//  AppConfigSwift Example
//
//  App config: application configuration
//  A convenience model used by the build environment selector and has strict typing
//  Important when using model structure to define default values: always reflect a production situation
//

import UIKit
import AppConfigSwift

class ExampleAppConfigModel : AppConfigBaseModel {
    
    // --
    // MARK: Model fields
    // --
    var name = "Production"
    var apiUrl = "https://production.example.com/"
    var networkTimeoutSec: Int = 20
    var acceptAllSSL = false
    var runType = ExampleAppConfigRunType.RunNormally

    
    // --
    // MARK: Field grouping and serialization
    // --
    override func map(_ mapper: AppConfigModelMapper) {
        mapper.map(key: "name", value: &name)
        mapper.map(key: "apiUrl", value: &apiUrl, category: "API related")
        mapper.map(key: "networkTimeoutSec", value: &networkTimeoutSec, category: "API related")
        mapper.map(key: "acceptAllSSL", value: &acceptAllSSL, category: "API related")
        mapper.map(key: "runType", value: &runType, fallback: .RunNormally, allValues: ExampleAppConfigRunType.allValues())
    }

}
