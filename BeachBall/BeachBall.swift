//
//  BeachBall.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/31/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit
import TwitterKit

class BeachBall: NSObject {
    var beachBallID: String
    var beachBallOwner: String
    var beachBallHistory: Array<BeachBallEvent> = []
    
    override init() {
        self.beachBallID = NSUUID().UUIDString
        self.beachBallOwner = Twitter.sharedInstance().session().userID
    }
    
    func saveBall() {
        var uniqueQuery : PFQuery = PFQuery(className: "BeachBall")
        uniqueQuery.whereKey("beachBallID", equalTo: beachBallID)
        uniqueQuery.countObjectsInBackgroundWithBlock({
            (number: Int32!, error: NSError!) -> Void in
            if number == 0 {
                var newEvent = PFObject(className: "BeachBall")
                newEvent["beachBallID"] = self.beachBallID
                newEvent["beachBallOwner"] = self.beachBallOwner
                newEvent["eventIDStrings"] = self.getEventIDStrings()
                
                newEvent.saveInBackgroundWithBlock({
                    (success: Bool!, error: NSError!) -> Void in
                    if error != nil {
                        println("\(error)")
                    }
                })
            } else {
                uniqueQuery.getFirstObjectInBackgroundWithBlock({
                    (event: PFObject!, error: NSError!) -> Void in
                    if error != nil {
                        println("\(error)")
                    } else {
                        event["eventIDStrings"] = self.getEventIDStrings()
                        
                        event.saveInBackgroundWithBlock({
                            (success: Bool!, error: NSError!) -> Void in
                            if error != nil {
                                println("\(error)")
                            }
                        })
                    }
                })

            }
        })
    }
    
    func addEvent(sender: String, receiver: String) {
        var newEvent = BeachBallEvent(beachBallID: self.beachBallID, sentFrom: sender, sentTo: receiver)
        self.beachBallHistory.append(newEvent)
        newEvent.saveEvent()
        self.saveBall()
    }
    
    private func getEventIDStrings() -> Array<String> {
        var eventIDArray: Array<String> = []
        for event: BeachBallEvent in self.beachBallHistory {
            eventIDArray.append(event.eventID)
        }
        return eventIDArray
    }
    
    func eventCount() -> Int {
        return self.beachBallHistory.count
    }
}
