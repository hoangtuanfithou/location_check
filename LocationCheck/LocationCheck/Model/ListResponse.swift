//
//  DoctorResponse.swift
//
//  Create on 1/3/2017
//  Copyright © 2017 GMO Media, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class DoctorResponse: BaseModel {

    var id: String?
    var about: String?
    var address: String?
    var name: String?
    var phone: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        id <- map["_id"]
        about <- map["about"]
        address <- map["address"]
        name <- map["name"]
        phone <- map["phone"]        
    }

}
