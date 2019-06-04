//
//  PusherUtil.swift
//  SeniorProject
//
//  Created by Patrick Cook on 6/8/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//
import SwiftyJSON
import Foundation
import PromiseKit
import PusherSwift

class PusherController: PusherDelegate {
    static let shared: PusherController = PusherController()
    
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
    
    func initPusherWithChannel(channel: String) {
        
        let channel = pusher.subscribe(channelName: channel)
        
        let _ = channel.bind(eventName: "queue-playback-changed", callback: { (data: Any?) -> Void in
            print("Pusher: queue-playback-changed")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-upvoted", callback: { (data: Any?) -> Void in
            print("Pusher: song-upvoted")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-added-to-queue", callback: { (data: Any?) -> Void in
            print("Pusher: song-added-to-queue")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
        
        let _ = channel.bind(eventName: "song-deleted-from-queue", callback: { (data: Any?) -> Void in
            print("Pusher: song-deleted-from-queue")
            let json = JSON(data!)
            self.refreshSelectedAndPlayingQueueAfterTrigger(json: json)
        })
    }
    
    
    func refreshSelectedAndPlayingQueueAfterTrigger(json: JSON) {
        let id = json["queueId"].intValue
            
        firstly {
            Api.shared.getQueue(id: id)
            }.then { (result) -> Void in
                mainStore.dispatch(FetchedSelectedQueueAction(selectedQueue: result))
            }.catch { (error) in
        }
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
