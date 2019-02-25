//
//  SongCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/23/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var queuedByLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    var checked: Bool = false
    var song: Song!
    
    @IBAction func voteButtonTapped(_ sender: Any) {
        if (checked) {
            song.unvote()
        } else {
            song.vote()
        }
        
        checked = !checked
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let origImage = UIImage(named: "up-arrow-2")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        voteButton.setImage(tintedImage, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

