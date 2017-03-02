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
    }
    
    private func getRegionInfo() {
        let regionRequest = RegionRequest()
        regionRequest.userInfo = "user info"
        
        SVProgressHUD.show()
        Alamofire.request(regionUrl, method: .get, parameters: regionRequest.toJSON()).responseObject { (response: DataResponse<RegionResponse>) in
            SVProgressHUD.dismiss()
            if response.result.isSuccess && response.response?.statusCode == 200,
                let region = response.result.value {
                self.startMonitoring(regionResponse: region)
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

extension ViewBusiness: CLLocationManagerDelegate {
    
    func requestLocation() {
        // location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring(regionResponse: RegionResponse) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            return
        }
        if let region = self.getRegion(regionResponse) {
            locationManager.startMonitoring(for: region)
        }
    }
    
    private func getRegion(_ regionResponse: RegionResponse) -> CLCircularRegion? {
        guard let latitude = regionResponse.latitude, let longitude = regionResponse.longitude, let radius = regionResponse.radius else {
            return nil
        }
        
        let rightRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let region = CLCircularRegion(center: coordinate, radius: rightRadius, identifier: "LocationCheck")
        
        region.notifyOnEntry = true
        return region
    }
    
    private func stopMonitoring(regionResponse: RegionResponse) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    private func showLocalNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            let content = UNMutableNotificationContent()
            content.title = "Entered"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 10.0,
                repeats: false)
            let request = UNNotificationRequest(identifier: "LocationCheck", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            self.showLocalNotification()
        }
    }
    
}

extension ViewBusiness: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}
