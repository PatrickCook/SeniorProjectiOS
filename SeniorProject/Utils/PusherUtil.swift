//
//  PusherUtil.swift
//  SeniorProject
//
//  Created by Patrick Cook on 6/8/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation
import PromiseKit
import PusherSwift

class PusherUtil: PusherDelegate {
    static let shared: PusherUtil = PusherUtil()
    
    var pusher: Pusher! = nil
    
    private init() {
        
        let pusherClientOptions = PusherClientOptions(
            authMethod: .inline(secret: "3282b1f895978bb203e8"),
            host: .cluster("us2")
        )
        
        pusher = Pusher(key: "f24ae820c20aa1b1acda", options: pusherClientOptions)
        pusher.delegate = self
        
        pusher.connect()
    }
    
    func startPusher() {
        print("Init - PusherUtil")
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        //print("old: \(old.stringValue()) -> new: \(new.stringValue())")
    }
    
    func subscribedToChannel(name: String) {
        print("Subscribed to \(name)")
    }
    
    func debugLog(message: String) {
        //print(message)
    }
}
