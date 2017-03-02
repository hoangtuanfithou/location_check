//
//  Constants.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
var mainContext: NSManagedObjectContext {
    if #available(iOS 10.0, *) {
        return appDelegate.persistentContainer.viewContext
    } else {
        return appDelegate.managedObjectContext
    } 
}

let regionUrl = "http://beta.json-generator.com/api/json/get/N18P-91qf?indent=2"
let listUrl = "http://beta.json-generator.com/api/json/get/EyDYcqyqG?indent=1"
