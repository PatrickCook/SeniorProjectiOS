//
//  QueueModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/1/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Queue {
    
    let id: Int
    let name: String
    let curMembers: Int
    let maxMembers: Int
    let curSongs: Int
    let maxSongs: Int
    let isPrivate: Bool
    let owner: Int
    let songs: [Song]
    
    var description: String {
        return "Queue: { id: \(id), name: \(name), curMember: \(curMembers), maxMember: \(maxMembers), curSongs: \(curSongs), maxSongs: \(curSongs), isPrivate: \(isPrivate), owner: \(owner)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let owner = data["owner"] as? Int,
            let name = data["name"] as? String,
            let curMembers = data["cur_members"] as? Int,
            let maxMembers = data["max_members"] as? Int,
            let curSongs = data["cur_songs"] as? Int,
            let maxSongs = data["max_songs"] as? Int,
            let isPrivate = data["private"] as? Bool
        else {
            print("Error serializing Queue.")
            return nil
        }
        
        self.id = id
        self.name = name
        self.owner = owner
        self.curMembers = curMembers
        self.maxMembers = maxMembers
        self.curSongs = curSongs
        self.maxSongs = maxSongs
        self.isPrivate = isPrivate
        self.songs = []
    }
}
