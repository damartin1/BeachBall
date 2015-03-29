//
//  BeachBallBuddies.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/29/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class BeachBallBuddies: NSObject {
    
    var beachBallBuddies : Array<String> = []
    
    override init() {
        super.init()
        getTwitterFriends({
            friends in
            let friendsPredicate = NSPredicate(format: "userID IN %@", friends)
            let query = PFQuery(className: "User", predicate: friendsPredicate)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects.count) users.")
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            println(object.objectId)
                            self.beachBallBuddies.append(object.objectForKey("userID") as String)
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                }
            }
        })
    }
    
    func getTwitterFriends(completionHandler: (friends: Array<String>) -> ()) {
        var friendsArray : Array<String> = []
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/friends/ids.json"
        let params = ["user_id": Twitter.sharedInstance().session().userID]
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
                    let friendList : JSON = json["ids"]
                    for (index: String, subJson: JSON) in friendList {
                        friendsArray.append(subJson.stringValue)
                        println("\(subJson)")
                    }
                    completionHandler(friends: friendsArray)
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
   
}
