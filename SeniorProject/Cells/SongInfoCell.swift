//
//  SongInfoCell.swift
//  SeniorProject
//
//  Created by Jin Young Jeong on 5/16/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation
import UIKit

class SongInfoCell{
    var time : String
    var title : String
    var image : String
    var artist : String
    var songURL : String
    var previewURL : String

    init (title: String, image: String, artist: String, songURL: String, previewURL: String, time: String){
        self.title = title
        self.image = image
        self.artist = artist
        self.songURL = songURL
        self.previewURL = previewURL
        self.time = time
    }
}
