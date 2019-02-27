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
            voteButton.tintColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            song.unvote()
        } else {
            voteButton.tintColor =  #colorLiteral(red: 0.3803921569, green: 0.6980392157, blue: 0.9764705882, alpha: 1)
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

