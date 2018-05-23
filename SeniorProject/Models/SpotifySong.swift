//
//  SpotifySong.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/22/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class SpotifySong {
    
    let title: String
    let image: String
    let artist: String
    let songURL: String
    let previewURL: String
    let time: String
    
    var description: String {
        return "SpotifySong: { title: \(title), image: \(image), artist: \(artist), songURL: \(songURL), previewURL: \(previewURL), time: \(time) }"
    }
    
    public init(title: String, image: String, artist: String, songURL: String, previewURL: String, time: String) {
        self.title = title
        self.image = image
        self.artist = artist
        self.songURL = songURL
        self.previewURL = previewURL
        self.time = time
    }
    
    
}
