//
//  Parse.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 5/1/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation

struct ParseKeys {
    static let parseAppIDHeaderField = "X-Parse-Application-Id"
    static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    static let restAPIKeyHeaderField = "X-Parse-REST-API-Key"
    static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
}


struct ParseURL {
    static let apiMethod = "https://parse.udacity.com/parse/classes/StudentLocation"
    
}

struct ParseOptionalParameters {
    static var limitNumber: Int?
    static var limitParameter: String? {
        if limitNumber != nil {
            return "limit=\(limitNumber!)"
        } else {
            return nil
        }
    }
    static var skipNumber: Int?
    static var skipParameter: String? {
        if skipNumber != nil {
            return "skip=\(skipNumber!)"
        } else {
            return nil
        }
    }
    static var orderBy: String?
    static var ascending: Bool = true // default true
    static var ascendingValue: String {
        if ascending == true {
            return ""
        } else {
            return "-"
        }
    }
    static var orderParameter: String? {
        if orderBy != nil {
            return "order=\(ascendingValue)\(orderBy!)"
        } else {
            return nil
        }
    }
}

