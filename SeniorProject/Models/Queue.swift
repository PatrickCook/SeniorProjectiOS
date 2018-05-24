//
//  QueueModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/1/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Queue {
    
    var id: Int
    var name: String
    var curMembers: Int
    var maxMembers: Int
    var curSongs: Int
    var maxSongs: Int
    var isPrivate: Bool
    var owner: String
    var songs: [Song]
    
    var currentSong: Song? {
        set {}
        get { return songs.first }
    }
    
    var description: String {
        return "Queue: { id: \(id), name: \(name), curMember: \(curMembers), maxMember: \(maxMembers), curSongs: \(curSongs), maxSongs: \(curSongs), isPrivate: \(isPrivate), owner: \(owner)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let owner = data["ownerUsername"] as? String,
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
        self.currentSong = nil
    }
    
    func sort() {
        songs = songs.sorted(by: {
            if ($0.votes == $1.votes) {
                return $0.createdAt > $0.createdAt
            } else {
                return $0.votes > $1.votes
            }     
        })
    }
    
    func enqueue(song: Song) {
        songs.append(song)
    }
    
    func dequeue() {
        songs.removeFirst()
    }
    
    func clearQueue() {
        songs.removeAll()
    }
}
