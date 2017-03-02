//
//  BaseModel.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import ObjectMapper

class BaseModel: Mappable {
    
    init() {
        // Request function
    }
    
    required init?(map: Map) {
        // Mappable request function
    }
    
    func mapping(map: Map) {
        // Mappable request function
    }
    
}
