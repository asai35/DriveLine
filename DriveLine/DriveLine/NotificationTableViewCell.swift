//
//  NotificationTableViewCell.swift
//  DriveLine
//
//  Created by mac on 8/23/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var commentImageView: UIImageView! {
        didSet {
            commentImageView.layer.cornerRadius = commentImageView.frame.size.width / 2
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
