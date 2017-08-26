//
//  JobDetailViewController.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 Cheong Yu. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController {
    
    var listing: JobListing!

    @IBOutlet weak var textView: UITextView!

}

extension JobDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = listing.details.data(using: .utf8), let text = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            textView.attributedText = text
        } else {
            textView.attributedText = NSAttributedString(string: listing.details)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
