//
//  GitHubJobsTests.swift
//  GitHubJobsTests
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 CYANware Software Solutions. All rights reserved.
//

import XCTest
import CoreLocation
@testable import GitHubJobs
import Alamofire
import PromiseKit
import SwiftyJSON

class GitHubJobsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSampleRequest() {
        let request = expectation(description: "HTTP GET request")
        let url = "https://jobs.github.com/positions.json?description=python&location=new+york"
        Alamofire.request(url, method: .get).responseJSON().then { json -> Void in
            let jobListings = JSON(json)
            XCTAssert(jobListings.array != nil && jobListings.arrayValue.count > 0, "Job listing array is empty")
            print("Found \(jobListings.arrayValue.count) listings")
            for job in jobListings.arrayValue {
                let listing = JobListing(id: job["id"].stringValue, company: job["company"].stringValue, companyLogo: job["company_logo"].stringValue, title: job["title"].stringValue, location: job["location"].stringValue, details: "", apply: "")
                print("\(listing)")
            }
        }.always {
            request.fulfill()
        }.catch { error in
            XCTFail("\(error.localizedDescription)")
        }
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("HTTP GET timeout: \(error.localizedDescription)")
            }
        }
    }
    
    func testJobListing() {
        let listing = JobListing(id: "", company: "Primatech", companyLogo: "", title: "Janitor", location: "Odessa, TX", details: "", apply: <#String#>)
        print("\(listing)")
        XCTAssert(listing.company == "Primatech" && listing.title == "Janitor" && listing.location == "Odessa, TX" && listing.details == "")
    }
    
    func testLocation() {
        let zip = Location.cityOrZip("79760")
        let city = Location.cityOrZip("Odessa, TX")
        let coordinates = Location.coordinates(CLLocationCoordinate2D(latitude: 31.8765908, longitude: -102.41359330))
        let latLong = Location.latLong(31.8765908, -102.41359330)
        print("Locations: \(zip), \(city), \(coordinates), \(latLong)")
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
