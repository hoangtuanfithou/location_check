//
//  RegionResponse.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class RegionResponse: BaseModel {

    var latitude: Float?
    var longitude: Float?
    var radius: Int?

    override func mapping(map: Map) {
        super.mapping(map: map)
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        radius <- map["radius"]        
    }

}
