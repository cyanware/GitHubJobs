//
//  JobListing.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 CYANware Software Solutions. All rights reserved.
//

import Foundation

struct JobListing {

    let id: String
    let company: String
    let companyLogo: String
    let title: String
    let location: String
    let details: String
    let apply: String

}


extension JobListing: CustomDebugStringConvertible {
 
    var debugDescription: String {
        return "JobListing: { company: \(company), title: \(title), location: \(location) }"
    }

}
