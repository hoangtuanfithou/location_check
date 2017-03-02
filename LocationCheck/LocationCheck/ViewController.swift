//
//  ViewController.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/1/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    var listDoctor: [DoctorResponse]?
    private let viewBusiness = ViewBusiness()
    
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
