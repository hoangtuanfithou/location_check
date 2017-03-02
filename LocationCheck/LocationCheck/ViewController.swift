//
//  ViewController.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit

//1. Please write a single view application that needs to send some data (any arbitrary JSON) using HTTP POST to URL1, ONLY using Wifi network. If the result contains fields latitude, longitude and radius, then create a Region Monitoring Alert with the given data. You are also required to write codes that push a local notification with message “Entered" if the user entered this region.
//2. Send some other data (other JSON) request to URL2 ONLY when it is on Cellular data. If it gets a collection of doctors (or any other) then please show them on table view, list view, etc. and save them locally (using SQLite, CoreData or Realm, etc.)

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    var listDoctor: [DoctorResponse]?
    
    let viewBusiness = ViewBusiness()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBusiness.viewController = self
        viewBusiness.setup()
    }
    
    func showListData(listResponse: [DoctorResponse]) {
        self.listDoctor = listResponse
        self.tableView?.reloadData()
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
