//
//  RecentLocationsTableViewController.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit

class RecentLocationsTableVC: TabBarChildVC, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Storyboard
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingSpinner(true)
        updateStudentLocations(sender: self) { success in
            self.showLoadingSpinner(false)
            guard success == true else {
                return
            }
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func logout(_ sender: Any) {
        showLoadingSpinner(true)
        logoutOfUdacity()
    }
    @IBAction func refresh(_ sender: Any) {
        showLoadingSpinner(true)
        updateStudentLocations(sender: self) { success in
            self.showLoadingSpinner(false)
            guard success == true else {
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view protocol
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.shared().forStudent.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let recentLocationCell = (tableView.dequeueReusableCell(withIdentifier: "RecentLocationCell", for: indexPath) as? RecentLocationTableViewCell) {
            let locationInfo = StudentLocations.shared().forStudent[indexPath.item]
            let firstName = locationInfo.firstName
            let lastName = locationInfo.lastName
            let url = locationInfo.mediaURL
            recentLocationCell.nameLabel.text = "\(firstName) \(lastName)"
            recentLocationCell.locationURLLabel.text = url
            
            cell = recentLocationCell
        }
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaURL = StudentLocations.shared().forStudent[indexPath.item].mediaURL
        openMediaURL(mediaURL)
    }
}
