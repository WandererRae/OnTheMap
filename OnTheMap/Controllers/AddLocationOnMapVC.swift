//
//  AddLocationOnMapVC.swift
//  OnTheMap
//
//  Created by Shannon on 6/11/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit
import MapKit

class AddLocationOnMapVC: UIViewController, MKMapViewDelegate {
    
    // MARK: - Storyboard
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var postStudentLocationButton: UIButton!
    
    // MARK: - Declarations
    
    var locationMarkerCoordinate: CLLocationCoordinate2D  {
        get {
            return mapView.centerCoordinate
        }
    }
    var mapBounds: MKCoordinateRegion?
    var locationMarker = MKPointAnnotation()
    var mediaURL: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.region = mapBounds!
        updateLocationMarker()
    }
    
    // MARK: - IB Actions
    
    @IBAction func postStudentLocation(_ sender: Any) {
        showLoadingSpinner(true)
        reverseGeocodeLocationMarker() { placemark in
            guard let uniqueKey = UdacityClient.shared().userInfo?.parseUniqueKey else {
                self.showLoadingSpinner(false)
                self.showAlert(message: "Missing unique key")
                return
            }
            
            guard let city = placemark.locality else {
                self.showLoadingSpinner(false)
                self.showAlert(message: "Could not find city name")
                return
            }
            guard let state = placemark.administrativeArea else {
                self.showLoadingSpinner(false)
                self.showAlert(message: "Could not find state/province name")
                return
            }
            
            guard let postInfo = ParseClient.LocationPost.Info.init(
                createdAt: StudentLocations.shared().forUser?.createdAt ?? nil,
                firstName: (UdacityClient.shared().userInfo?.firstName)!,
                lastName: (UdacityClient.shared().userInfo?.lastName)!,
                latitude: self.mapView.centerCoordinate.latitude,
                longitude: self.mapView.centerCoordinate.longitude,
                mapString: "\(city), \(state)",
                mediaURL: self.mediaURL!,
                objectID: StudentLocations.shared().forUser?.objectID ?? nil,
                uniqueKey: uniqueKey
                ) else {
                    self.showLoadingSpinner(false)
                    self.showAlert(message: "Could not create post info")
                    return
            }
            ParseClient.shared().request(
                ParseClient.shared().postUserLocation(postInfo: postInfo)) {data, error in
                    guard error == nil else {
                        self.showLoadingSpinner(false)
                        self.showAlert(message: error!)
                        return
                    }
                    guard data != nil else {
                        self.showLoadingSpinner(false)
                        self.showAlert(message: "Post request failed")
                        return
                    }
                    ParseClient.shared().convertPostResponseDataToLocationEntry(data!, postInfo: postInfo) { entry, error in
                        guard error == nil else {
                            self.showLoadingSpinner(false)
                            self.showAlert(message: error!)
                            return
                        }
                        guard entry != nil else {
                            self.showLoadingSpinner(false)
                            self.showAlert(message: "No location entry")
                            return
                        }
                        StudentLocations.shared().forUser = entry!
                        self.showLoadingSpinner(false)
                        self.successfullyPostedLocation()
                    }
            }
        }
    }
    
    // MARK: Private functions
    
    private func updateLocationMarker() {
        locationMarker.coordinate = locationMarkerCoordinate
        mapView.addAnnotation(locationMarker)
    }
    
    private func reverseGeocodeLocationMarker (completion: @escaping (_ placemark: CLPlacemark) -> Void) {
        let location = CLLocation.init(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let geocode = CLGeocoder()
        geocode.reverseGeocodeLocation(location) { (placemarkArray, error) in
            guard error == nil else {
                self.showAlert(message: (error as? String)!)
                return
            }
            guard placemarkArray != nil else {
                self.showAlert(message: "Unknown")
                return
            }
            let placemark = placemarkArray!.first!
            completion(placemark)
        }
    }
    
    func successfullyPostedLocation() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success!", message: "Your location has been updated", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("Location updated successfully")
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Map View
    
    internal func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateLocationMarker()
    }
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
