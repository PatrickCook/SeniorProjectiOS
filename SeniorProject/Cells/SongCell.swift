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
        voteButton.tintColor = checked ? #colorLiteral(red: 0.1647058824, green: 0.7215686275, blue: 0.3450980392, alpha: 1) : #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let origImage = UIImage(named: "up-arrow-2")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        voteButton.setImage(tintedImage, for: .normal)
        voteButton.tintColor = checked ? #colorLiteral(red: 0.1647058824, green: 0.7215686275, blue: 0.3450980392, alpha: 1) : #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

