//
//  SongSearchCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/1/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class SongSearchCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songImageLabel: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    var spotifySong: SpotifySong!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setSongForCell(spotifySong: SpotifySong) {
        self.spotifySong = spotifySong
        
        if spotifySong.previewURI == "null" {
            playButton.isEnabled = false
        } else {
            playButton.isEnabled = true
        }
    }

    @IBAction func playPressed(_ sender: UIButton) {
        if (!MusicPlayer.shared.isPreviewPlaying) {
            MusicPlayer.shared.downloadAndPlayPreviewURL(url: URL(string: spotifySong.previewURI)!)
        } else {
            MusicPlayer.shared.stopPreviewURL()
        }
    }
}
