//
//  Location.swift
//  GitHubJobs
//
//  Created by Cheong Yu on 8/26/17.
//  Copyright © 2017 Cheong Yu. All rights reserved.
//

import Foundation
import CoreLocation

enum Location {

    case cityOrZip(String)
    case coordinates(CLLocationCoordinate2D)
    case latLong(CLLocationDegrees, CLLocationDegrees)

}


extension Location: CustomStringConvertible {

    var description: String {
        switch self {
        case let .cityOrZip(location):
            return location
        case let .coordinates(coordinate2D):
            return "lat=\(coordinate2D.latitude)&long=\(coordinate2D.longitude)"
        case let .latLong(latitude, longitude):
            return "lat=\(latitude)&long=\(longitude)"
        }
    }

}
