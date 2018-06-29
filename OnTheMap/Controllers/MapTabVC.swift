//
//  MapTabbedViewController.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit
import MapKit

class MapTabVC: TabBarChildVC, MKMapViewDelegate {
    
    // MARK: - Storyboard
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        updateStudentLocations(sender: self) { success in
            guard success == true else {
                return
            }
            self.updatePinsOnMap()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func logout(_ sender: Any) {
        showLoadingSpinner(true)
        logoutOfUdacity()
    }
    
    @IBAction func refresh(_ sender: Any?) {
        showLoadingSpinner(true)
        updateStudentLocations(sender: self) { success in
            self.showLoadingSpinner(false)
            guard success == true else {
                return
            }
            self.updatePinsOnMap()
        }
    }
    
    // MARK: - Map View
    
    private func updatePinsOnMap() {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            for (_, locationInfo) in StudentLocations.shared().forStudent.enumerated() {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: locationInfo.latitude, longitude: locationInfo.longitude)
                annotation.title = "\(locationInfo.firstName) \(locationInfo.lastName)"
                annotation.subtitle = locationInfo.mediaURL
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            openMediaURL((view.annotation?.subtitle!)!)
        }
    }
}
