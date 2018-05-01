//
//  RecentLocationTableViewCell.swift
//  OnTheMap
//
//  Created by Bogue Shannon on 5/1/18.
//  Copyright © 2018 WandererRae. All rights reserved.
//

import UIKit

class RecentLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var locationURLLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
