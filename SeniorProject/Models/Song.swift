//
//  SongModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/9/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class Song {
    
    let id: Int
    let votes: Int
    let spotifyURI: String
    
    
    var description: String {
        return "Song: { id: \(id), uri: \(spotifyURI), votes: \(votes)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let votes = data["votes"] as? Int,
            let spotifyURI = data["spotify_uri"] as? String
        else {
            print("Error serializing Song.")
            return nil
        }
        
        self.id = id
        self.votes = votes
        self.spotifyURI = spotifyURI
    }
}
