//
//  QueueCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/23/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class QueueCell: UITableViewCell {
    
    @IBOutlet var queueUIImage: UIImageView!
    @IBOutlet weak var queueNameLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
