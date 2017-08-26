//
//  JobListingViewController.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 Cheong Yu. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON


class JobListingViewController: UITableViewController {
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var jobListings = [JobListing]()
}


extension JobListingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.title = "GitHub Jobs"
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - UITableDataSource

extension JobListingViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobListings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobListingCell", for: indexPath)

        cell.textLabel?.text = jobListings[indexPath.row].company
        cell.detailTextLabel?.text = "\(jobListings[indexPath.row].title)\n\(jobListings[indexPath.row].location)"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}

// MARK: - Navigation

extension JobListingViewController {

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? JobDetailViewController, let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            let listing = jobListings[indexPath.row]
            viewController.listing = listing
        }
    }

}

// MARK: - UISearchBarDelegate

extension JobListingViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        jobListings.removeAll()

        let endpoint = "https://jobs.github.com/positions.json"
        var parameters = [String: String]()
        parameters["description"] = searchBar.text

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(endpoint, method: .get, parameters: parameters).responseJSON().then { json -> Void in
            let listings = JSON(json)
            for job in listings.arrayValue {
                let listing = JobListing(company: job["company"].stringValue, title: job["title"].stringValue, location: job["location"].stringValue, details: job["description"].stringValue)
                self.jobListings.append(listing)
            }
        }.always {
            searchBar.resignFirstResponder()
            self.jobListings.sort { $0.company < $1.company }
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in
            print("Error: \(error.localizedDescription)")
        }
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }

}
