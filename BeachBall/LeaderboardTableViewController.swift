//
//  LeaderboardTableViewController.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/29/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

let nc = NSNotificationCenter.defaultCenter()
let kNotifyUserDataReady = "com.beachball.twtrUserDataReady"

class LeaderboardTableViewController: UITableViewController {
    
    let buddieID: Array<String> = [
        "513376667",
        "121118692",
        "37291805",
        "22330739",
        "20444825",
        "2742628802",
        "608724203",
        "32385638",
        "74759560",
        "83888782",
        "105596427",
        "17518588",
        "46834274",
        "40918816",
        "15862891",
        "125163655",
        "10121422",
        "14353392",
        "7718362"

    ]
    
    var twtrUserInfo: Array<TWTRUsers> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        nc.addObserver(self,
            selector: Selector("reloadTVC:"),
            name: kNotifyUserDataReady,
            object: nil
        )
        
        self.getAllBuddieData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return buddieID.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("buddieCell", forIndexPath: indexPath) as LeaderboardTableViewCell
        if twtrUserInfo.isEmpty == false {
            let user = twtrUserInfo[indexPath.row]
            cell.avatarImageView.image = UIImage(data: user.avatarImageData)
            cell.fullName.text = user.fullName
            cell.userName.text = user.userName
            cell.descriptionText.text = user.descriptionText
        }
        return cell
    }
    
    func reloadTVC(notification: NSNotification) {
        self.tableView.reloadData()
    }

    func getAllBuddieData() {
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
        let params = ["user_id": ",".join(self.buddieID)]
        println("\(params)")
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET", URL: statusesShowEndpoint, parameters: params,
            error: &clientError)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                (response, data, connectionError) -> Void in
                if (connectionError == nil) {
                    var jsonError : NSError?
                    let json = JSON(data: data)
                    for (index: String, subJson: JSON) in json {
                        self.twtrUserInfo.append(TWTRUsers(json: subJson))
                    }
                    
                }
                else {
                    println("Error: \(connectionError)")
                }
            }
        }
        else {
            println("Error: \(clientError)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
