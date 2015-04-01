//
//  TWTRUser.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/30/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class TWTRUsers: NSObject {
    var fullName: String = ""
    var userName: String = ""
    var descriptionText: String = ""
    var avatarImageData: NSData = NSData()
    
    init(buddieID: String) {
        super.init()
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
        let params = ["user_id": buddieID]
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
                    
                    let avatarURLString: String = json[0]["profile_image_url"].stringValue
                    self.descriptionText = json[0]["description"].stringValue
                    self.fullName = json[0]["name"].stringValue
                    self.userName = json[0]["screen_name"].stringValue
                    
                    let avatarURL = NSURL(string: avatarURLString)
                    self.avatarImageData = NSData(contentsOfURL: avatarURL!)!
                    println("\(self.fullName)")
                    nc.postNotificationName(kNotifyUserDataReady, object: nil)
                    
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
    
    init(json: JSON) {
        super.init()
        
        let avatarURLString: String = json["profile_image_url"].stringValue
        self.descriptionText = json["description"].stringValue
        self.fullName = json["name"].stringValue
        self.userName = json["screen_name"].stringValue
        
        let avatarURL = NSURL(string: avatarURLString)
        self.avatarImageData = NSData(contentsOfURL: avatarURL!)!
        println("\(self.fullName)")
        nc.postNotificationName(kNotifyUserDataReady, object: nil)
    }
    
}
