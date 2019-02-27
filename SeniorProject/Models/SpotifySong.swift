//
//  SpotifySong.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/22/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation
import PromiseKit

class SpotifySong {

    let title: String
    let artist: String
    let imageURI: String
    var image: UIImage?
    let spotifyURI: String
    let previewURI: String
    
    
    var description: String {
        return "SpotifySong: { title: \(title), image: \(imageURI), artist: \(artist), songURL: \(spotifyURI), previewURL: \(previewURI)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let artist = data["artist"] as? String,
            let imageURI = data["album_uri"] as? String,
            let spotifyURI = data["spotify_uri"] as? String,
            let previewURI = data["preview_uri"] as? String
        else {
            print("Error serializing Song.")
            return nil
        }
        
        self.title = title
        self.artist = artist
        self.imageURI = imageURI
        self.spotifyURI = spotifyURI
        self.previewURI = previewURI
    }
}

