//
//  CustomTableViewCell.swift
//  Invayt
//
//  Created by Vincent Villalta on 11/11/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var evetnImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventOrganizer: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var attendees: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.evetnImage.layer.cornerRadius = self.evetnImage.frame.size.width / 2
        self.evetnImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
