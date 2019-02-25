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
    var isPlaying: Bool
    var playingUserId: Int
    var name: String
    var curMembers: Int
    var maxMembers: Int
    var curSongs: Int
    var maxSongs: Int
    var isPrivate: Bool
    var owner: String
    var songs: [Song]
    
    var description: String {
        return "Queue: { id: \(id), name: \(name), isPlaying: \(isPlaying), playingUserId: \(playingUserId) songs: \(songs.count)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let owner = data["ownerUsername"] as? String,
            let name = data["name"] as? String,
            let curMembers = data["curMembers"] as? Int,
            let maxMembers = data["maxMembers"] as? Int,
            let curSongs = data["curSongs"] as? Int,
            let maxSongs = data["maxSongs"] as? Int,
            let isPrivate = data["isPrivate"] as? Bool,
            let isPlaying = data["isPlaying"] as? Bool,
            let playingUserId = data["playingUserId"] as? Int
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
        self.isPlaying = isPlaying
        self.playingUserId = playingUserId
        self.songs = []
    }
    
    func sort() {
        songs = songs.sorted(by: {
            if $0.isPlaying {
                return $0.isPlaying
            } else if ($0.votes == $1.votes) {
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
        if (songs.count > 0) {
            songs.removeFirst()
        }
    }
    
    func skip() {
        dequeue()
    }
    
    func hasNext() -> Bool {
        return songs.count > 0
    }
    
    func clearQueue() {
        songs.removeAll()
    }
}
