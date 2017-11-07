//
//  JobListingViewController.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 CYANware Software Solutions. All rights reserved.
//

import UIKit
import CoreGraphics
import Alamofire
import AlamofireImage
import MBProgressHUD
import PromiseKit
import SwiftyJSON


class JobListingViewController: UITableViewController {
    
    required init?(coder decoder: NSCoder) {
        // Create a blank placeholder image for table cells
        let size = CGSize(width: 66, height: 66)
        UIGraphicsBeginImageContext(size)
        defaultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();

        super.init(coder: decoder)
    }
    
    @IBOutlet weak var footerLabel: UILabel!
    
    let jobListingsPerPage = 50
    let defaultImage: UIImage
    var searchController: UISearchController!
    var jobListings = [JobListing]()
    var location: Location?
}


extension JobListingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        navigationItem.title = "GitHub Jobs"

        configureSearchController()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextPage))
        footerLabel.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension JobListingViewController {
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search by keywords, e.g. python"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }

    func search(for keywords: String?) {
        let endpoint = "https://jobs.github.com/positions.json"
        var parameters = [String: String]()
        parameters["description"] = keywords?.replacingOccurrences(of: " ", with: "+")
        if let location = location {
            switch location {
            case let .cityOrZip(cityOrZip):
                parameters["location"] = cityOrZip.replacingOccurrences(of: " ", with: "+")
            case let .coordinates(coordinate2D):
                parameters["lat"] = String(coordinate2D.latitude)
                parameters["long"] = String(coordinate2D.longitude)
            case let .latLong(latitude, longitude):
                parameters["lat"] = String(latitude)
                parameters["long"] = String(longitude)
            }
        }
        parameters["page"] = String(jobListings.count / jobListingsPerPage)
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Searching..."
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(endpoint, method: .get, parameters: parameters).responseJSON().then { json -> Void in
            let listings = JSON(json)
            for job in listings.arrayValue {
                let listing = JobListing(id: job["id"].stringValue, company: job["company"].stringValue, companyLogo: job["company_logo"].stringValue, title: job["title"].stringValue, location: job["location"].stringValue, details: job["description"].stringValue, apply: job["how_to_apply"].stringValue)
                self.jobListings.append(listing)
            }
        }.always {
            let count = self.jobListings.count
            let footerText = count > 1 ? "\(count) job listings" : "\(count) job listing"
            if count > 0 && count % self.jobListingsPerPage == 0 {
                self.footerLabel.text = footerText + ". Next page..."
            } else {
                self.footerLabel.text = footerText
            }
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            hud.hide(animated: true)
            self.searchController.dismiss(animated: true, completion: nil)
        }.catch { error in
            print("Error: \(error.localizedDescription)")
        }
    }

    func nextPage() {
        if jobListings.count != 0 && jobListings.count % jobListingsPerPage == 0 {
            search(for: searchController.searchBar.text)
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

        cell.imageView?.image = defaultImage
        let listing = jobListings[indexPath.row]
        if let url = URL(string: listing.companyLogo) {
            let resizer = AspectScaledToFitSizeFilter(size: defaultImage.size)
            cell.imageView?.af_setImage(withURL: url, filter: resizer)
        }
        cell.textLabel?.text = listing.company
        cell.detailTextLabel?.text = "\(listing.title)\n\(listing.location)"

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
        if let viewController = segue.destination as? FilterViewController {
            viewController.location = location
            viewController.delegate = self
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
        footerLabel.text = nil
        search(for: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        // TODO: feature to be added later
    }

}

// MARK: - UISearchResultsUpdating

extension JobListingViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        // Intentionally left blank
    }

}
