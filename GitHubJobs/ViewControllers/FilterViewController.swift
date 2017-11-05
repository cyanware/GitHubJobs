//
//  FilterViewController.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 CYANware Software Solutions. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController {
    
    weak var delegate: JobListingViewController?
    var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let locationText = location?.description,
            let reuseIdentifier = cell.reuseIdentifier,
            reuseIdentifier == "LocationCell"
            else { return }
        cell.detailTextLabel?.text = locationText
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let alert = UIAlertController(title: "Location", message: "Enter location filter", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            if let cityOrZip = alert.textFields?[0].text {
                cell?.detailTextLabel?.text = cityOrZip
                self.location = Location.cityOrZip(cityOrZip)
            }
        }

        alert.addTextField { textField in
            textField.placeholder = "City name or zip code"
        }
        alert.addAction(cancel)
        alert.addAction(ok)

        present(alert, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

// MARK: - Navigation

extension FilterViewController {
    
    override func didMove(toParentViewController parent: UIViewController?) {
        delegate?.location = location
    }
    
}
