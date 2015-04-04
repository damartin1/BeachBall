//
//  BeachBallEvent.swift
//  BeachBall
//
//  Created by Robert Borkowski on 3/31/15.
//  Copyright (c) 2015 Robert Borkowski. All rights reserved.
//

import UIKit

class BeachBallEvent: NSObject {
    
    enum Result: String {
        case Passed = "Passed"
        case Dropped = "Dropped"
    }
    
    enum Status: String {
        case InProgress = "InProgress"
        case Done = "Done"
    }
    
    var eventID: String
    var beachBallID: String
    var beachBallSender: String
    var beachBallReceiver: String
    var eventSentTime: NSDate
    var eventFinishTime: NSDate?
    var eventResult: Result?
    var eventStatus: Status = .InProgress
    
    init(beachBallID: String, sentFrom: String, sentTo: String) {
        self.eventID = NSUUID().UUIDString
        self.beachBallID = beachBallID
        self.beachBallSender = sentFrom
        self.beachBallReceiver = sentTo
        self.eventSentTime = NSDate()
        
        super.init()
    }
    
    func saveEvent() {
        var uniqueQuery : PFQuery = PFQuery(className: "BeachBallEvent")
        uniqueQuery.whereKey("eventID", equalTo: self.eventID)
        uniqueQuery.countObjectsInBackgroundWithBlock({
            number in
            if number.0 == 0 {
                var newEvent = PFObject(className: "BeachBallEvent")
                newEvent["eventID"] = self.eventID
                newEvent["beachBallID"] = self.beachBallID
                newEvent["beachBallSender"] = self.beachBallSender
                newEvent["beachBallReceiver"] = self.beachBallReceiver
                newEvent["eventSentTime"] = self.eventID
                newEvent["eventStatus"] = self.eventStatus.rawValue
                
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
                        event["eventResult"] = self.eventResult?.rawValue
                        event["eventStatus"] = self.eventStatus.rawValue
                        if self.eventFinishTime != nil {
                            event["eventFinishTime"] = self.eventFinishTime
                        }
                        
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
}
