//
//  RegionMonitorHelper.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

class RegionMonitorHelper: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    private let locationManager = CLLocationManager()
    
    func requestLocation() {
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
    
    // Get Region for Monitor
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
    
    // Create local push notifcation
    private func showLocalNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            let content = UNMutableNotificationContent()
            content.title = "Entered"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
            let request = UNNotificationRequest(identifier: "LocationCheck", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    // Uisng LocationNotificationTrigger
    private func setupLocationNotificationTrigger(_ regionResponse: RegionResponse) {
        guard let latitude = regionResponse.latitude, let longitude = regionResponse.longitude, let radius = regionResponse.radius else {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            let content = UNMutableNotificationContent()
            content.body = "Entered"
            
            let rightRadius = min(radius, self.locationManager.maximumRegionMonitoringDistance)
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = CLCircularRegion(center: center, radius: rightRadius, identifier: "LocationCheck")
            region.notifyOnEntry = true
            let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: true)
            
            let request = UNNotificationRequest(identifier: "LocationCheck", content: content, trigger: locationTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            self.showLocalNotification()
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
}
