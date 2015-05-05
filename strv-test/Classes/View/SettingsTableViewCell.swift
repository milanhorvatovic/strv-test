//
//  SettingsTableViewCell.swift
//  strv-test
//
//  Created by Milan Horvatovic on 05/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak private(set) var titleLabel: UILabel?;
    @IBOutlet weak private(set) var unitsLabel: UILabel?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
