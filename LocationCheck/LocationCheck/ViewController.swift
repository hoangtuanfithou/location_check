//
//  ViewController.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import AlamofireObjectMapper
import ReachabilitySwift
import CoreLocation
import UserNotifications

//1. Please write a single view application that needs to send some data (any arbitrary JSON) using HTTP POST to URL1, ONLY using Wifi network. If the result contains fields latitude, longitude and radius, then create a Region Monitoring Alert with the given data. You are also required to write codes that push a local notification with message “Entered" if the user entered this region.
//2. Send some other data (other JSON) request to URL2 ONLY when it is on Cellular data. If it gets a collection of doctors (or any other) then please show them on table view, list view, etc. and save them locally (using SQLite, CoreData or Realm, etc.)

let regionUrl = "http://beta.json-generator.com/api/json/get/N18P-91qf?indent=2"
let listUrl = "http://beta.json-generator.com/api/json/get/EyDYcqyqG?indent=1"

class ViewController: UIViewController {

    let reachability = Reachability()!
    var listDoctor: [DoctorResponse]?
    let locationManager = CLLocationManager()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilitySetup()
        requestLocation()
    }
    
    private func reachabilitySetup() {
        reachability.whenReachable = { [weak self] reachability in
            if reachability.isReachableViaWiFi {
                //                self?.getRegionInfo()
                self?.getListData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        Alamofire.request(listUrl, method: .get, parameters: regionRequest.toJSON()).responseArray { (response: DataResponse<[DoctorResponse]>) in
            SVProgressHUD.dismiss()
            if response.result.isSuccess && response.response?.statusCode == 200,
                let listResponse = response.result.value {
                debugPrint(listResponse)
                self.listDoctor = listResponse
                self.tableView.reloadData()
            }
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDoctor?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        let doctor = listDoctor?[indexPath.row]
        cell.textLabel?.text = doctor?.name
        cell.detailTextLabel?.text = doctor?.address
        
        return cell
    }

}

extension ViewController: CLLocationManagerDelegate {

    func requestLocation() {
        // location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
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

extension ViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}
