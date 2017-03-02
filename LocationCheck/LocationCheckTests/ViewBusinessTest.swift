//
//  ViewBusinessTest.swift
//  LocationCheck
//
//  Created by Nguyen Hoang Tuan on 3/2/17.
//  Copyright © 2017 NHT. All rights reserved.
//

import XCTest

@testable import LocationCheck

class ViewBusinessTest: XCTestCase {
    
    let viewBusiness = ViewBusiness()
    let viewController = ViewController()
    
    override func setUp() {
        super.setUp()
        viewBusiness.viewController = viewController
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetRegionInfo() {
        if !viewBusiness.reachability.isReachable {
            return
        }
        let getExpectation = expectation(description: "server return")
        viewBusiness.getRegionInfo { (regionResponse) in
            XCTAssert(regionResponse.latitude != nil, "get region")
            getExpectation.fulfill()
        }
        waitForExpectations(timeout: 60) { (error) in
        }
    }
    
    func testGetListData() {
        if !viewBusiness.reachability.isReachable {
            return
        }
        let getExpectation = expectation(description: "server return")
        viewBusiness.getListData { (listResponse) in
            XCTAssert(listResponse.count > 0, "get list data")
            getExpectation.fulfill()
        }
        waitForExpectations(timeout: 60) { (error) in
        }
    }
    
    func testShowSavedListData() {
        if !viewBusiness.reachability.isReachable {
            return
        }
        
        var countList = 0
        let getExpectation = expectation(description: "server return")
        viewBusiness.getListData { (listResponse) in
            XCTAssert(listResponse.count > 0, "get list data")
            countList = listResponse.count
            getExpectation.fulfill()
        }
        waitForExpectations(timeout: 60) { (error) in
        }
        
        viewBusiness.showSavedListData()
        XCTAssert(countList == viewController.listDoctor?.count, "saved list equal server return")
    }
    
}
