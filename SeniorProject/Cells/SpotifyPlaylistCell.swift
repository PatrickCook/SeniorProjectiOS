//
//  SpotifyPlaylistCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/20/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import UIKit

class SpotifyPlaylistCell: UITableViewCell {
    
    @IBOutlet var playlistNameLabel: UILabel!
    
    @IBOutlet var playlistUIImage: UIImageView!
    @IBOutlet var playlistSongCountLabel: UILabel!
   
    var spotifyPlaylist: SpotifyPlaylist!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
