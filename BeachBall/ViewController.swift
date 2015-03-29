//
//  ViewController.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/28/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Twitter.sharedInstance().logOut()
        
        if Twitter.sharedInstance().session() != nil {
            println("session \(Twitter.sharedInstance().session())")
            let buddies = BeachBallBuddies()
        } else {
            let logInButton = TWTRLogInButton(logInCompletion: {
                (session: TWTRSession!, error: NSError!) in
                // play with Twitter session
                println("signed in as \(session.userName)")
                
                if self.checkIfExistingUser(Twitter.sharedInstance().session().userID) == false {
                    var userObject: PFObject = PFObject(className: "User")
                    userObject.setObject(session.userID, forKey: "userID")
                    userObject.setObject(session.userName, forKey: "userName")
                    self.getTwitterUserDetails({
                        details in
                        userObject.setObject(details["avatarURL"], forKey: "avatarURL")
                        userObject.setObject(details["description"], forKey: "description")
                        userObject.setObject(details["fullName"], forKey: "fullName")
                        userObject.saveInBackgroundWithBlock({
                            (success: Bool!, error: NSError!) -> Void in
                            if (success != nil) {
                                NSLog("Object created with id: \(userObject.objectId)")
                                let buddies = BeachBallBuddies()
                            } else {
                                NSLog("%@", error)
                            }
                        })
                    })
                } else {
                    let buddies = BeachBallBuddies()
                    println("User exists for id \(Twitter.sharedInstance().session().userID)")
                }
                
            })
            logInButton.center = self.view.center
            self.view.addSubview(logInButton)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TODO: Thread blocking with a synchronous query. Should make this work async eventually.
    func checkIfExistingUser(twitterUserID: String) -> Bool {
        var query = PFQuery(className:"User")
        query.whereKey("userID", equalTo:twitterUserID)
        var unique = query.countObjects()
        if unique == 0 {
            return false
        } else {
            let alertController = UIAlertController(title: "User Exists!", message:
                "Welcome Back, \(Twitter.sharedInstance().session().userName)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return true
        }
    }
    
    func getTwitterUserDetails(completionHandler: (details: Dictionary<String, String>) -> ()) {
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
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
                    
                    let avatarURL: String = json[0]["profile_image_url"].stringValue
                    let description: String = json[0]["description"].stringValue
                    let fullName: String = json[0]["name"].stringValue
                    
                    completionHandler(details: [
                        "avatarURL":avatarURL,
                        "description":description,
                        "fullName": fullName
                        ]
                    )
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

