//
//  MyDriveCell.swift
//  DriveLine
//
//  Created by mac on 5/9/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import MapKit
class MyDriveCell: UITableViewCell {

    @IBOutlet var lblDriveType: UILabel!
    @IBOutlet var lblDriveName: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var driveImageView: UIImageView!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnAddVideo: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
