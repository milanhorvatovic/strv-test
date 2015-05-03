//
//  ForecastTableViewCell.swift
//  strv-test
//
//  Created by Milan Horvatovic on 02/05/15.
//  Copyright (c) 2015 Milan Horvatovic. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet weak private(set) var weatherImageView: UIImageView?;
    @IBOutlet weak private(set) var nameLabel: UILabel?;
    @IBOutlet weak private(set) var weatherConditionLabel: UILabel?;
    @IBOutlet weak private(set) var temperatureLabel: UILabel?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
