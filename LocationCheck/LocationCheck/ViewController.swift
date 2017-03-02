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

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilitySetup()
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
                self.setupLocationNotificationTrigger(region)
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

extension ViewController: UNUserNotificationCenterDelegate {
    
    func setupLocationNotificationTrigger(_ regionResponse: RegionResponse) {
        guard let latitude = regionResponse.latitude, let longitude = regionResponse.longitude, let radius = regionResponse.radius else {
            return
        }

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            let content = UNMutableNotificationContent()
            content.body = "Entered"
            
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

