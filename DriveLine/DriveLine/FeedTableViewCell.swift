//
//  FeedTableViewCell.swift
//  DriveLine
//
//  Created by mac on 9/5/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

//    @IBOutlet weak var imvUserAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblDriveTitle: UILabel!
    @IBOutlet weak var lblStyle: UILabel!
    @IBOutlet weak var lblToStart: UILabel!
    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imvMap: UIImageView!
    @IBOutlet weak var btnPlayVideo: UIButton!

    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDrive: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imvLike: UIImageView!
    @IBOutlet weak var btnOtherUserProfile: UIButton!
    
    var driveId: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var imvUserAvatar: UIImageView! {
        didSet {
            imvUserAvatar.layer.cornerRadius = imvUserAvatar.frame.size.width / 2
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
