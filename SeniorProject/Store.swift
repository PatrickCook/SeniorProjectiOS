//
//  Store.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/10/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Store {
    static var currentUser: User? = nil
    static var currentQueues: [Queue] = []
    static var selectedQueue: Queue? = nil
    static var currentSong: Song? = nil
    
    class func setCurrentUser(user: User) {
        currentUser = user
    }
    class func setCurrentQueues(queuesToAdd: [Queue]) {
        currentQueues = queuesToAdd
    }
    class func setSelectedQueue(index: Int) {
        selectedQueue = currentQueues[index]
    }
    class func setCurrentSong(index: Int) {
        currentSong = selectedQueue?.songs[index]
    }
}
