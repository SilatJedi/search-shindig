//
//  resultsTableViewCell.swift
//  Search Shindig
//
//  Created by James Anderson on 2/1/17.
//  Copyright © 2017 James Anderson. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
