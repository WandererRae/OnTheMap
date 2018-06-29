//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Shannon on 5/30/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // Udacity user data should be shared throughout app
    
    class func shared() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - User data
    
    var sessionInfo: SessionInfo? = nil
    var userInfo: UserInfo? = nil
    
    // MARK: - Generate URL request
    
    func loginRequest(username: String, password: String) -> URLRequest {
        var request = URLRequest(url: URL(string: Constants.authUrlString)!)
        request.httpMethod = Constants.HTTPMethod.post
        request.addValue(Constants.authAddValues, forHTTPHeaderField: Constants.HeaderField.accept)
        request.addValue(Constants.authAddValues, forHTTPHeaderField: Constants.HeaderField.contentType)
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        return request
    }
    
    func userDataRequest (_ user: String) -> URLRequest {
        let request = URLRequest(url: URL(string: "\(Constants.userDataUrlString)\(user)")!)
        return request
    }
    
    func logoutRequest () -> URLRequest? {
        var request = URLRequest(url: URL(string: Constants.authUrlString)!)
        request.httpMethod = Constants.HTTPMethod.delete
        let sharedCookieJar = HTTPCookieStorage.shared
        var xsrfCookie: HTTPCookie? = nil
        for cookie in sharedCookieJar.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        guard let anXsrfCookie = xsrfCookie else {
            return nil
        }
        request.setValue(anXsrfCookie.value, forHTTPHeaderField: Constants.HeaderField.xsrfToken)
        return request
    }
    
    // MARK: - Send request
    
    func send (request: URLRequest?, completion: @escaping (_ data: Data?, _ error: String?) -> Void) {
        guard request != nil else {
            completion(nil, "Invalid request")
            return
        }
        let session = URLSession.shared
        let authUrlTask = session.dataTask(with: request!) { rawData, response, error in
            guard error == nil else {
                completion(nil, (error as? String)!)
                return
            }
            guard let usefulData = rawData?.removeUdacitySecurityCharacters() else {
                completion(nil, "Could not remove Udacity Security Characters")
                return
            }
            completion(usefulData, nil)
        }
        authUrlTask.resume()
    }
    
    // MARK: Decode data from Udacity
    
    func decodeLoginData (_ data: Data, completion: @escaping (_ sessionInfo: SessionInfo?, _ error: String?) -> Void) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            completion(nil, "Could not serialize JSON")
            return
        }
        guard let dict = json as? NSDictionary else {
            completion(nil, "Could not cast JSON as dict")
            return
        }
        if let loginFail = dict["status"] as? Int {
            completion(nil, "\(loginFail): \((dict["error"] as? String)!)")
        }
        guard let loginSuccess = dict["account"] as? NSDictionary else {
            completion(nil, "Could not find dictionary key for account")
            return
        }
        guard let session = dict["session"] as? NSDictionary else {
            completion(nil, "Could not find dictionary key for session")
            return
        }
        guard let registered = loginSuccess["registered"] as? Bool else {
            completion(nil, "Could not find dictionary key for registered")
            return
        }
        guard registered == true else {
            completion(nil, "User is not registered")
            return
        }
        guard let userID = loginSuccess["key"] as? String else {
            completion(nil, "Could not find dicionary key for key")
            return
        }
        guard let sessionID = session["id"] as? String else {
            completion(nil, "Could not find dictionary key for id")
            return
        }
        guard let expiration = session["expiration"] as? String else {
            completion(nil, "Could not find dictionary key for expiration")
            return
        }
        let thisSession = SessionInfo.init(sessionId: sessionID, userId: userID, registered: registered, expiration: expiration)
        completion(thisSession, nil)
    }
    
    func decodeUserData (_ data: Data, completion: @escaping (_ userInfo: UserInfo?, _ error: String?) -> Void) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            completion(nil, "Could not serialize JSON")
            return
        }
        guard let dict = json as? [String: AnyObject] else {
            completion(nil, "Could not get dict")
            return
        }
        guard let user = dict["user"] as? [String:AnyObject] else {
            completion(nil, "Could not find user entry \n\(dict)")
            return
        }
        guard let userKey = user["key"] as? String else {
            completion(nil, "Could not get user key")
            return
        }
        guard let firstName = user["first_name"] as? String else {
            completion(nil, "Could not get first name")
            return
        }
        guard let lastName = user["last_name"] as? String else {
            completion(nil, "Could not get last name")
            return
        }
        let thisUser = UserInfo.init(firstName: firstName, lastName: lastName, parseUniqueKey: userKey)
        completion(thisUser, nil)
    }
    
    func decodeLogoutData (_ data: Data, completion: @escaping (_ error: String?) -> Void) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            completion("Could not serialize JSON")
            return
        }
        guard let dict = json as? [String: AnyObject] else {
            completion("Could not get dict")
            return
        }
        guard let session = dict["session"] as? [String:AnyObject] else {
            completion("Could not find session entry \n\(dict)")
            return
        }
        completion(nil)
    }
    
    // MARK: - Structs
    
    struct Constants {
        static let authUrlString = "https://www.udacity.com/api/session"
        static let userDataUrlString = "https://www.udacity.com/api/users/"
        static let authAddValues = "application/json"
        struct HeaderField {
            static let accept = "Accept"
            static let contentType = "Content-Type"
            static let xsrfToken = "X-XSRF-TOKEN"
        }
        struct HTTPMethod {
            static let post = "POST"
            static let delete = "DELETE"
        }
    }
    struct SessionInfo {
        var sessionId: String
        var userId: String
        var registered: Bool
        var expiration: String
        
        init (sessionId: String, userId: String, registered: Bool, expiration: String) {
            self.sessionId = sessionId
            self.userId = userId
            self.registered = registered
            self.expiration = expiration
        }
    }
    struct UserInfo {
        var firstName: String
        var lastName: String
        var parseUniqueKey: String
        
        init (firstName: String, lastName: String, parseUniqueKey: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.parseUniqueKey = parseUniqueKey
        }
        
    }
}

extension Data {
    func removeUdacitySecurityCharacters() -> Data {
        let range = Range(5..<self.count)
        return self.subdata(in: range)
    }
}
