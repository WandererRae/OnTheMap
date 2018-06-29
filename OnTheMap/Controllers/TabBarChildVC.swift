//
//  TabBarChildVC.swift
//  OnTheMap
//
//  Created by Shannon on 5/30/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit

class TabBarChildVC: UIViewController {
}
extension TabBarChildVC {
    
        func logoutOfUdacity() {
            UdacityClient.shared().send(request: UdacityClient.shared().logoutRequest()) { data, error in
                guard error == nil else {
                    self.showAlert(message: error!)
                    return
                }
                guard data != nil else {
                    self.showAlert(message: "Nil logout data")
                    return
                }
                UdacityClient.shared().decodeLogoutData(data!) { error in
                    guard error == nil else {
                        self.showAlert(message: error!)
                        return
                    }
                    
                    UdacityClient.shared().sessionInfo = nil
                    UdacityClient.shared().userInfo = nil
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                    
                }
            }
        }
        
    func updateStudentLocations(sender: UIViewController, completion: @escaping (_ success: Bool) -> Void){
        
        ParseClient.shared().request(
            ParseClient.shared().get(
                ParseClient.shared().studentLocations())) { (data, error) in
                guard error == nil else {
                    completion(false)
                    self.showAlert(message: error!)
                    return
                }
                guard data != nil else {
                    completion(false)
                    self.showAlert(message: "Nil student location data")
                    return
                }
                ParseClient.shared().convertGetResponseDataToLocationEntries(data!) { entries, error in
                    guard error == nil else {
                        completion(false)
                        self.showAlert(message: error!)
                        return
                    }
                    guard entries != nil else {
                        completion(false)
                        self.showAlert(message: "Nil student location entries")
                        return
                    }
                    StudentLocations.shared().forStudent = entries!
                    completion(true)
                }
            }
        }
        
        func createGoogleSearchURL(_ string: String) -> URL {
            let base = "https://www.google.com/search?q="
            let query = string.replacingOccurrences(of: " ", with: "+")
            let final = URL(string: base + query)!
            return final
        }
    func openMediaURL (_ string: String){
            let app = UIApplication.shared
            if let url = URL(string: string) {
                if app.canOpenURL(url) {
                    app.open(url)
                } else {
                    app.open(createGoogleSearchURL(string))
                }
            }
        }
}
