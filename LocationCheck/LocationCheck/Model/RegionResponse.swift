//
//  RegionResponse.swift
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import Foundation
import ObjectMapper

class RegionResponse: BaseModel {

    var latitude: Double?
    var longitude: Double?
    var radius: Double?

    override func mapping(map: Map) {
        super.mapping(map: map)
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        radius <- map["radius"]        
    }

}
