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
    var name: String = "Production"
    var apiUrl: String = "https://production.example.com/"
    var networkTimeoutSec: Int = 20
    var acceptAllSSL: Bool = false
    var runType: ExampleAppConfigRunType = ExampleAppConfigRunType.RunNormally

    
    // --
    // MARK: Field grouping and serialization
    // --
    override func map(mapper: AppConfigModelMapper) {
        mapper.map("name", value: &name)
        mapper.map("apiUrl", value: &apiUrl, category: "API related")
        mapper.map("networkTimeoutSec", value: &networkTimeoutSec, category: "API related")
        mapper.map("acceptAllSSL", value: &acceptAllSSL, category: "API related")
        mapper.map("runType", value: &runType, fallback: .RunNormally, allValues: ExampleAppConfigRunType.allValues())
    }

}
