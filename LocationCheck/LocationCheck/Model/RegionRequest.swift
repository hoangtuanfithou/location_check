//
//  RegionRequest.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class RegionRequest: BaseModel {

    var dateTime: String?
    var userInfo: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        dateTime <- map["dateTime"]
        userInfo <- map["userInfo"]        
    }

}
