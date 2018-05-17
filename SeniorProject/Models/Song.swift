//
//  SongModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/9/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Song {
    
    var id: Int
    var votes: Int
    var spotifyURI: String
    var queueId: Int
    var userId: Int
    
    
    var description: String {
        return "Song: { id: \(id), uri: \(spotifyURI), votes: \(votes)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let spotifyURI = data["spotify_uri"] as? String,
            let queueId = data["queueId"] as? Int,
            let userId = data["userId"] as? Int
        else {
            print("Error serializing Song.")
            return nil
        }
        
        self.id = id
        self.votes = 0
        self.spotifyURI = spotifyURI
        self.queueId = queueId
        self.userId = userId
    }
}
