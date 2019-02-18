//
//  Song.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/24/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation
import PromiseKit

class Song {
    let id: Int
    let queueId: Int
    let queuedBy: String
    let title: String
    let artist: String
    let imageURI: String
    let spotifyURI: String
    let previewURI: String
    let votes: Int
    let createdAt: Double
    let updatedAt: Double
    var locked: Bool
    
    var description: String {
        return "SpotifySong: { title: \(title), image: \(imageURI), artist: \(artist), songURL: \(spotifyURI), previewURL: \(previewURI)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let title = data["title"] as? String,
            let artist = data["artist"] as? String,
            let imageURI = data["albumURI"] as? String,
            let spotifyURI = data["spotifyURI"] as? String,
            let previewURI = data["previewURI"] as? String,
            let votes = data["votes"] as? Int,
            let queueId = data["queueId"] as? Int,
            let user = data["queuedBy"] as? [String : String],
            let createdAt = data["createdAt"] as? String,
            let updatedAt = data["updatedAt"] as? String
        else {
            print("Error serializing Song.")
            return nil
        }
        
        self.id = id
        self.title = title
        self.artist = artist
        self.imageURI = imageURI
        self.spotifyURI = spotifyURI
        self.previewURI = previewURI
        self.votes = votes
        self.queueId = queueId
        self.queuedBy = user["username"]!
        self.createdAt = Utils.shared.convertDateToEpoch(dateString: createdAt)
        self.updatedAt = Utils.shared.convertDateToEpoch(dateString: updatedAt)
        self.locked = false
    }
    
    func vote () {
        Api.shared.voteSong(song: self)
            .catch { (error) in
                print(error)
            }
    }
    
    func unvote () {
        Api.shared.unvoteSong(song: self)
            .catch { (error) in
                print(error)
            }
    }
    
    func lock() {
        print("Song: locking")
        locked = true
    }
    
    func unlock() {
         print("Song: unlocking")
        locked = false
    }
}
