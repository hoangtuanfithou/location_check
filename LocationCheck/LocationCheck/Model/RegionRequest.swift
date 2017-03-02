//
//  RegionRequest.swift
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
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
