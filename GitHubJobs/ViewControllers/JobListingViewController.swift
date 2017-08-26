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
    @IBOutlet weak var footerLabel: UILabel!
    
    let jobListingsPerPage = 50
    var jobListings = [JobListing]()
}


extension JobListingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.title = "GitHub Jobs"
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextPage))
        footerLabel.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension JobListingViewController {

    func search(for keywords: String?) {
        let endpoint = "https://jobs.github.com/positions.json"
        var parameters = [String: String]()
        parameters["description"] = keywords
        parameters["page"] = String(jobListings.count / jobListingsPerPage)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(endpoint, method: .get, parameters: parameters).responseJSON().then { json -> Void in
            let listings = JSON(json)
            for job in listings.arrayValue {
                let listing = JobListing(company: job["company"].stringValue, title: job["title"].stringValue, location: job["location"].stringValue, details: job["description"].stringValue)
                self.jobListings.append(listing)
            }
        }.always {
            self.searchBar.resignFirstResponder()
            let count = self.jobListings.count
            let footerText = count > 1 ? "\(count) job listings" : "\(count) job listing"
            if count > 0 && count % self.jobListingsPerPage == 0 {
                self.footerLabel.text = footerText + ". Next page..."
            } else {
                self.footerLabel.text = footerText
            }
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in
            print("Error: \(error.localizedDescription)")
        }
    }

    func nextPage() {
        if jobListings.count != 0 && jobListings.count % jobListingsPerPage == 0 {
            search(for: searchBar.text)
        }
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        jobListings.removeAll()
        tableView.reloadData()
        footerLabel.text = "Searching..."
        search(for: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
    }

}