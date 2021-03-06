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
    private let regionMonitor = RegionMonitorHelper()
    weak var viewController: ViewController?
    
    func setup() {
        reachabilitySetup()
        regionMonitor.requestLocation()
    }
    
    private func reachabilitySetup() {
        reachability.whenReachable = { [weak self] reachability in
            if reachability.isReachableViaWiFi {
                self?.getRegionInfo()
                self?.getListData()

            } else if reachability.isReachableViaWWAN {
                self?.getListData()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
        }
        
        if !reachability.isReachable {
            showSavedListData()
        }
    }
    
    // MARK : Get data
    internal func showSavedListData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Doctor")
        do {
            let fetchedEntities = try mainContext.fetch(fetchRequest)
            if let doctors = fetchedEntities as? [DoctorResponse] {
                viewController?.showListData(listResponse: doctors)
            }
        } catch {
        }
    }
    
    internal func getRegionInfo(completion: ((RegionResponse) -> Void)? = nil) {
        let regionRequest = RegionRequest()
        
        SVProgressHUD.show()
        Alamofire.request(regionUrl, method: .post, parameters: regionRequest.toJSON()).responseObject { [weak self] (response: DataResponse<RegionResponse>) in
            SVProgressHUD.dismiss()
            if response.result.isSuccess && response.response?.statusCode == 200,
                let region = response.result.value {
                self?.regionMonitor.startMonitoring(regionResponse: region)
                completion?(region)
            }
        }
    }
    
    internal func getListData(completion: (([DoctorResponse]) -> Void)? = nil) {
        let regionRequest = RegionRequest()
        
        SVProgressHUD.show()
        Alamofire.request(listUrl, method: .post, parameters: regionRequest.toJSON()).responseArray { [weak self] (response: DataResponse<[DoctorResponse]>) in
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
                completion?(listResponse)
            }
        }
    }
    
}
