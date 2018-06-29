//
//  StudentLocationEntry.swift
//  OnTheMap
//
//  Created by Shannon on 6/8/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocationEntry {
    
    var createdAt: String
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectID: String
    var uniqueKey: String
    var updatedAt: String
    
    init?(_ data: [String:AnyObject], completion: @escaping (_ error: String?) -> Void) {
        guard let createdAt = data["createdAt"] as? String else {
            completion("createdAt failed")
            return nil
        }
        guard let firstName = data["firstName"] as? String else {
            completion("firstName failed")
            return nil
        }
        guard let lastName = data["lastName"] as? String else {
            completion("lastName failed")
            return nil
        }
        guard let latitude = data["latitude"] as? CLLocationDegrees else {
            completion("latitude failed")
            return nil
        }
        guard let longitude = data["longitude"] as? CLLocationDegrees else {
            completion("longitude failed")
            return nil
        }
        guard let mapString = data["mapString"] as? String else {
            completion("mapString failed")
            return nil
        }
        guard let mediaURL = data["mediaURL"] as? String else {
            completion("mediaURL failed")
            return nil
        }
        guard let objectID = data["objectId"] as? String else {
            completion("objectID failed")
            return nil
        }
        guard let uniqueKey = data["uniqueKey"] as? String else {
            completion("uniqueKey failed")
            return nil
        }
        guard let updatedAt = data["updatedAt"] as? String else {
            completion("updatedAt failed")
            return nil
        }
        
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName =  lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectID = objectID
        self.uniqueKey = uniqueKey
        self.updatedAt = updatedAt
    }
    init?(locationPost: ParseClient.LocationPost.Info,  createdAt: String, objectID: String, updatedAt: String) {
        self.createdAt = createdAt
        self.firstName = locationPost.firstName
        self.lastName =  locationPost.lastName
        self.latitude = locationPost.latitude
        self.longitude = locationPost.longitude
        self.mapString = locationPost.mapString
        self.mediaURL = locationPost.mediaURL
        self.objectID = objectID
        self.uniqueKey = locationPost.uniqueKey
        self.updatedAt = updatedAt
    }
}
