//
//  AddLocationVC.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit
import MapKit

class AddLocationVC: UIViewController, MKLocalSearchCompleterDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Storyboard
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cityStateTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    // MARK: - Declarations
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var selectedLocation: MKLocalSearchCompletion?
    private var location: MKLocalSearchResponse?
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.isHidden = true
        searchResultsTableView.isHidden = true
        
        searchCompleter.delegate = self
        searchResultsTableView.delegate = self
        cityStateTextField.delegate = self
        mediaURLTextField.delegate = self
        
        searchResultsTableView.dataSource = self
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: cityStateTextField,
            queue: OperationQueue.main,
            using: {notification in
                self.searchCompleter.queryFragment = self.cityStateTextField.text!
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(Notification.Name.UITextFieldTextDidChange)
    }
    
    // MARK: - IBActions
    
    @IBAction func findLocation(_ sender: Any) {
        guard cityStateTextField.text != "" else {
            errorLabel.text = "Enter a location"
            return
        }
        guard mediaURLTextField.text != "" else {
            errorLabel.text = "Enter a URL"
            return
        }
        checkIfCityStateInputIsValid()
    }
    
    @IBAction func cancelAddLocation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Check city, state input
    
    func checkIfCityStateInputIsValid() {
        showLoadingSpinner(true)
        if selectedLocation == nil { // Make sure user input is valid location and get info
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = cityStateTextField.text!
            let search = MKLocalSearch(request: request)
            search.start() { (response, error) in
                self.processMKLocalSearchResults(response, error)
            }
        } else { // get info for location
            let request = MKLocalSearchRequest.init(completion: selectedLocation!)
            let search = MKLocalSearch(request: request)
            search.start() { (response, error) in
                self.processMKLocalSearchResults(response, error)
            }
        }
    }
    
    func processMKLocalSearchResults (_ response: MKLocalSearchResponse?, _ error: Error?) {
        guard error == nil else {
            showLoadingSpinner(false)
            showAlert(message: (error as? String)!)
            return
        }
        guard response != nil else {
            showLoadingSpinner(false)
            showAlert(message: "Unknown")
            return
        }
        location = response
        showLoadingSpinner(false)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addLocationOnMap", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addLocationOnMap" {
            if let addLocationOnMap = segue.destination as? AddLocationOnMapVC {
                addLocationOnMap.mapBounds = location!.boundingRegion
                addLocationOnMap.mediaURL = mediaURLTextField.text!
            }
        }
    }
    
    // MARK: - Table view protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleter.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "defaultCell")
        cell.textLabel?.text = searchCompleter.results[indexPath.item].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = searchCompleter.results[indexPath.item]
        selectedLocation = selection
        cityStateTextField.text = selection.title
        cityStateTextField.resignFirstResponder()
        searchResultsTableView.isHidden = true
    }
    
    // MARK: - MK local search completer
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResultsTableView.reloadData()
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        selectedLocation = nil
        self.searchResultsTableView.reloadData()
    }
    
    // MARK: - Text field protocol
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityStateTextField {
            searchResultsTableView.isHidden = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchResultsTableView.isHidden = true
        textField.resignFirstResponder()
        return true
    }
}


