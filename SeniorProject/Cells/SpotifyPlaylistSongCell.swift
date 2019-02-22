//
//  SpotifySongCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/21/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import UIKit

class SpotifyPlaylistSongCell: UITableViewCell {
    
    @IBOutlet var songTitleLabel: UILabel!
    @IBOutlet var songArtistLabel: UILabel!
    @IBOutlet var songUIImage: UIImageView!
    
    
    
    var spotifySong: SpotifySong!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

