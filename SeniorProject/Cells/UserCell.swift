//
//  UserCell.swift
//  SeniorProject
//
//  Created by Patrick Cook on 4/23/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    var checked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
