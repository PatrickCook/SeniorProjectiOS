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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

