//
//  JobDetailViewController.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 CYANware Software Solutions. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var decriptionTextView: UITextView!
    @IBOutlet weak var applyTextView: UITextView!

    var listing: JobListing!

}

extension JobDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = listing.details.data(using: .utf16), let text = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            decriptionTextView.attributedText = text
        } else {
            decriptionTextView.attributedText = NSAttributedString(string: listing.details)
        }
        if let data = listing.apply.data(using: .utf16), let text = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) {
            applyTextView.attributedText = text
        } else {
            applyTextView.attributedText = NSAttributedString(string: listing.apply)
        }
    }

    override func viewDidLayoutSubviews() {
        decriptionTextView.setContentOffset(.zero, animated: false)
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
