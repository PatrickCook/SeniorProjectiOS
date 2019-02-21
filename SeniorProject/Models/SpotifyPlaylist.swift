//
//  SpotifyPlaylist.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/20/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//
import Foundation
import PromiseKit

class SpotifyPlaylist {
    
    let playlistID: String
    let name: String
    let imageURI: String
    let playlistImage: UIImage
    let songCount: Int
    let songs: [SpotifySong]

    var description: String {
        return "SpotifySong: { name: \(name), image: \(imageURI)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["playlist_id"] as? String,
            let name = data["name"] as? String,
            let imageURI = data["image_uri"] as? String,
            let count = data["song_count"] as? Int
            else {
                print("Error serializing Playlist.")
                return nil
        }
        
        self.playlistID = id
        self.name = name
        self.imageURI = imageURI
        self.songs = []
        self.songCount = count
        
        let mainImageURL = URL(string: imageURI)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        self.playlistImage = UIImage(data: mainImageData! as Data)!
    }
}

