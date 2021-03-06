//
//  ProfileTableViewCell.swift
//  DriveLine
//
//  Created by mac on 9/7/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class OfflineTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDriveTitle: UILabel!
    @IBOutlet weak var lblStyle: UILabel!
    @IBOutlet weak var lblToStart: UILabel!
    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imvMap: UIImageView!
    @IBOutlet weak var btnAddVideo: UIButton!
    @IBOutlet weak var progressview: UIProgressView!

    @IBOutlet weak var btnDelete: UIButton!
    var driveTag: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
