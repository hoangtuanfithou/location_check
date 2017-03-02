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
import CoreLocation
import UserNotifications
import CoreData

class ViewBusiness: NSObject {

    let reachability = Reachability()!
    let locationManager = CLLocationManager()
    weak var viewController: ViewController?
    
    func reachabilitySetup() {
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
                self?.setupLocationNotificationTrigger(region)
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

extension ViewBusiness: UNUserNotificationCenterDelegate {
    
    func setupLocationNotificationTrigger(_ regionResponse: RegionResponse) {
        guard let latitude = regionResponse.latitude, let longitude = regionResponse.longitude, let radius = regionResponse.radius else {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            let content = UNMutableNotificationContent()
            content.title = "Entered"
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(center: center, radius: radius, identifier: "LocationCheck")
            region.notifyOnEntry = true
            let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: true)
            
            let request = UNNotificationRequest(identifier: "LocationCheck", content: content, trigger: locationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
}
