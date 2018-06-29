//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 5/1/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation

class ParseClient {

    
    class func shared() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - URL request location parameters
    
    func userLocations(key: String) -> [String] {
        var parameters: [String] = []
        parameters.append(Constants.SearchParameters.init().user(key: key))
        return parameters
    }
    
    func studentLocations() -> [String] {
        var parameters: [String] = []
        parameters.append(Constants.SearchParameters.order)
        parameters.append(Constants.SearchParameters.limit)
        return parameters
    }
    
    // MARK: - Create URL request
    
    func get(_ parameters: [String]) -> URLRequest? {
        let urlString = Constants.studentLocationUrlString + "?" + parameters.joined(separator: "&")
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(Constants.parseAppId, forHTTPHeaderField: Constants.parseAppIdHeaderField)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.restApiKeyHeaderField)
        return request
    }
    
    func postUserLocation (postInfo: LocationPost.Info) -> URLRequest {
        let post = LocationPost.init().createBody(for: postInfo)
        var urlString = Constants.studentLocationUrlString
        var postType: LocationPost.Kind = .new // Assume new post, changes to .update if objectID exists
        if let objectID = postInfo.objectID {
            urlString.append("/\(objectID)")
            postType = .update
        }
        var request = URLRequest(url: URL(string: urlString)!)
        switch postType {
        case .new:
            request.httpMethod = Constants.HTTPMethod.post
        case .update:
            request.httpMethod = Constants.HTTPMethod.put
        }
        request.addValue(Constants.parseAppId, forHTTPHeaderField: Constants.parseAppIdHeaderField)
        request.addValue(Constants.restApiKey, forHTTPHeaderField: Constants.restApiKeyHeaderField)
        request.addValue(Constants.authAddValues, forHTTPHeaderField: Constants.HeaderField.contentType)
        request.httpBody = post.data(using: .utf8)
        return request
    }
    
    // MARK: - Send URL request
    
    func request(_ urlRequest: URLRequest?, completion: @escaping (_ data: Data?, _ failureReason: String?) -> Void) {
        guard let request = urlRequest else {
            completion(nil, "Invalid URL request")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else{
                completion(nil, (error as? String)!)
                return
            }
            guard data != nil else {
                completion(nil, "No data")
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    // MARK: - Translate Parse data to student location entries
    
    func convertGetResponseDataToLocationEntries (_ data: Data, completion: @ escaping (_ entries: [StudentLocationEntry]?, _ failureReason: String?) -> Void) {
        guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            completion(nil, "Could not parse data as JSON")
            return
        }
        guard let resultsSingleEntryDictionary = parsedData as? NSDictionary else {
            completion(nil, "Could not parse JSON as dictionary")
            return
        }
        guard let resultsFound = resultsSingleEntryDictionary["results"] as? [[String:AnyObject]] else {
            completion(nil, "Could not get results dictionary")
            return
        }
        
        var entries: [StudentLocationEntry] = []
        
        for (index, info) in resultsFound.enumerated() {
            let entry = StudentLocationEntry.init(info) { error in
                guard error == nil else {
                    print("\n\(error!) at index: \(index)\n\(info)\n")
                    return
                }
            }
            if entry != nil {
                entries.append(entry!)
            }
        }
        completion(entries, nil)
    }
    
    
    func convertPostResponseDataToLocationEntry (_ data: Data, postInfo: LocationPost.Info, completion: @escaping (_ locationEntry: StudentLocationEntry?, _ failureReason: String?) -> Void) {
        guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            completion(nil, "Could not parse data as JSON")
            return
        }
        guard let dict = parsedData as? [String:AnyObject] else {
            completion(nil, "Could not get dict")
            return
        }
        guard let timeStamp = dict["updatedAt"] as? String ?? dict["createdAt"] as? String else {
            completion(nil, "No update time \(dict)")
            return
        }
        guard let objectID = postInfo.objectID ?? dict["objectId"] as? String else {
            completion(nil, "No object ID")
            return
        }
        guard let entry = StudentLocationEntry.init(
            locationPost: postInfo,
            createdAt: postInfo.createdAt ?? timeStamp,
            objectID: postInfo.objectID ?? objectID,
            updatedAt: timeStamp
            ) else {
                completion(nil, "Location Entry init failed")
                return
        }
        completion(entry, nil)
    }
    
    
    struct Constants {
        static let studentLocationUrlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let parseAppIdHeaderField = "X-Parse-Application-Id"
        static let parseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restApiKeyHeaderField = "X-Parse-REST-API-Key"
        static let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let authAddValues = "application/json"
        struct HeaderField {
            static let accept = "Accept"
            static let contentType = "Content-Type"
            static let xsrfToken = "X-XSRF-TOKEN"
        }
        struct HTTPMethod {
            static let post = "POST"
            static let put = "PUT"
        }
        struct SearchParameters {
            static let limit = "limit=100"
            static let order = "order=-updatedAt"
            func user (key: String) -> String {
                return "where=%7B%22uniqueKey%22%3A%22\(key)%22%7D"
            }
        }
    }
    
    struct LocationPost {
        enum Kind { case new, update}
        struct Info {
            var createdAt: String?
            var firstName: String
            var lastName: String
            var latitude: Double
            var longitude: Double
            var mapString: String
            var mediaURL: String
            var objectID: String?
            var uniqueKey: String
            
            init?(createdAt: String?, firstName: String, lastName: String, latitude: Double, longitude: Double, mapString: String, mediaURL: String, objectID: String?, uniqueKey: String) {
                self.createdAt = createdAt
                self.firstName = firstName
                self.lastName =  lastName
                self.latitude = latitude
                self.longitude = longitude
                self.mapString = mapString
                self.mediaURL = mediaURL
                self.objectID = objectID
                self.uniqueKey = uniqueKey
            }
        }
        func createBody (for locationPostInfo: Info) -> String {
            let body = "{\"uniqueKey\": \"\(locationPostInfo.uniqueKey)\", \"firstName\": \"\(locationPostInfo.firstName)\", \"lastName\": \"\(locationPostInfo.lastName)\",\"mapString\": \"\(locationPostInfo.mapString)\", \"mediaURL\": \"\(locationPostInfo.mediaURL)\",\"latitude\": \(locationPostInfo.latitude), \"longitude\": \(locationPostInfo.longitude)}"
            return body
        }
    }
}



