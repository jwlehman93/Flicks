//
//  MovieCell.swift
//  Flicks
//
//  Created by Jeremy Lehman on 1/29/17.
//  Copyright © 2017 Jeremy Lehman. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
