//
//  RecentLocationsTableViewController.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 4/19/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit

class RecentLocationsTableViewController: UITableViewController {
    
    @IBOutlet weak var logoutOfUdacityButton: UIBarButtonItem!
    @IBOutlet weak var refreshLocationListButton: UIBarButtonItem!
    @IBOutlet weak var addNewLocationButton: UIBarButtonItem!
    
    private var finalParseURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    @IBAction func logoutOfUdacity(_ sender: Any) {
    }
    
    @IBAction func refreshLocationList(_ sender: Any) {
    }
    
    @IBAction func addNewLocation(_ sender: Any) {
    }
    
    private func requestLocationData() {
        let timeoutInterval = 30.0
        let parseRequest = URLRequest(url: finalParseURL!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: timeoutInterval)
    }
    
    private func setParseURLString() -> URL? {
        var parseURLArray = [String]()
        parseURLArray.append(ParseURL.apiMethod)
        ParseOptionalParameters.limitNumber = 100
        parseURLArray.append(ParseOptionalParameters.limitParameter!)
        
        let string = parseURLArray.joined(separator: "?").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        finalParseURL = string
        return finalParseURL
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
