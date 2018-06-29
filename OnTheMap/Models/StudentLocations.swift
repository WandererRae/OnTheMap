//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Shannon on 6/8/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import Foundation

class StudentLocations {
    
    class func shared() -> StudentLocations {
        struct Singleton {
            static var sharedInstance = StudentLocations()
        }
        return Singleton.sharedInstance
    }
    
    var forStudent: [StudentLocationEntry] = []
    
    var forUser: StudentLocationEntry? = nil
    
    
}
