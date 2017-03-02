//
//  ViewBusiness.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import AlamofireObjectMapper
import ReachabilitySwift
import CoreData

class ViewBusiness: NSObject {

    let reachability = Reachability()!
    let regionMonitor = RegionMonitorHelper()
    weak var viewController: ViewController?
    
    func setup() {
        reachabilitySetup()
        regionMonitor.requestLocation()
    }
    
    private func reachabilitySetup() {
        reachability.whenReachable = { [weak self] reachability in
            if reachability.isReachableViaWiFi {
                self?.getRegionInfo()
            } else if reachability.isReachableViaWWAN {
                self?.getListData()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Unable to start notifier")
        }
        
        if !reachability.isReachable {
            showSavedListData()
        }
    }
    
    // MARK : Search history using Core Data
    private func showSavedListData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Doctor")
        do {
            let fetchedEntities = try mainContext.fetch(fetchRequest)
            if let doctors = fetchedEntities as? [DoctorResponse] {
                viewController?.showListData(listResponse: doctors)
            }
        } catch {
        }
    }
    
    private func getRegionInfo() {
        let regionRequest = RegionRequest()
        regionRequest.userInfo = "user info"
        
        SVProgressHUD.show()
        Alamofire.request(regionUrl, method: .get, parameters: regionRequest.toJSON()).responseObject { [weak self] (response: DataResponse<RegionResponse>) in
            SVProgressHUD.dismiss()
            if response.result.isSuccess && response.response?.statusCode == 200,
                let region = response.result.value {
                self?.regionMonitor.startMonitoring(regionResponse: region)
            }
        }
    }
    
    private func getListData() {
        let regionRequest = RegionRequest()
        regionRequest.userInfo = "user info"
        
        SVProgressHUD.show()
        Alamofire.request(listUrl, method: .get, parameters: regionRequest.toJSON()).responseArray { [weak self] (response: DataResponse<[DoctorResponse]>) in
            SVProgressHUD.dismiss()
            if response.result.isSuccess && response.response?.statusCode == 200,
                let listResponse = response.result.value {
                // clean
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Doctor")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try mainContext.persistentStoreCoordinator?.execute(deleteRequest, with: mainContext)
                } catch {
                    
                }
                // save
                appDelegate.saveContext()
                self?.viewController?.showListData(listResponse: listResponse)
            }
        }
    }

}
