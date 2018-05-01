//
//  MapTabbedViewController.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit
import MapKit

class MapTabbedViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutOfUdacityButton: UIBarButtonItem!
    @IBOutlet weak var refreshMapButton: UIBarButtonItem!
    @IBOutlet weak var addNewLocationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutOfUdacity(_ sender: Any) {
    }
    
    @IBAction func refreshMap(_ sender: Any) {
    }
    
    @IBAction func addNewLocation(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
