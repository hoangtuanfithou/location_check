//
//  DoctorResponse.swift
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class DoctorResponse: NSManagedObject, Mappable {

    @NSManaged var about: String?
    @NSManaged var address: String?
    @NSManaged var name: String?
    @NSManaged var phone: String?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: mainContext)
    }
    
    required init?(map: Map) {
        let entity = NSEntityDescription.entity(forEntityName: "Doctor", in: mainContext)
        super.init(entity: entity!, insertInto: mainContext)
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        about <- map["about"]
        address <- map["address"]
        name <- map["name"]
        phone <- map["phone"]        
    }

}
