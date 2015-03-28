//
//  ViewController.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/28/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Twitter.sharedInstance().session() != nil {
            println("session \(Twitter.sharedInstance().session())")
        } else {
            let logInButton = TWTRLogInButton(logInCompletion: {
                (session: TWTRSession!, error: NSError!) in
                // play with Twitter session
                println("signed in as \(session.userName)");
            })
            logInButton.center = self.view.center
            self.view.addSubview(logInButton)
        }
        getTwitterFriends()
        
        var testObject: PFObject = PFObject(className: "testObject")
        testObject.setObject("world", forKey: "hello")
        testObject.saveInBackgroundWithBlock({
            (success: Bool!, error: NSError!) -> Void in
            if (success != nil) {
                NSLog("Object created with id: \(testObject.objectId)")
            } else {
                NSLog("%@", error)
            }
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTwitterFriends() {
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
                        let json : AnyObject? =
                        NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError)
                        println("\(json)")
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

