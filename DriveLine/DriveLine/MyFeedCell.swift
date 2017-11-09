//
//  MyFeedCell.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class MyFeedCell: UITableViewCell {
    @IBOutlet weak var feedPersonImageView: UIImageView! {
        didSet {
            feedPersonImageView.layer.cornerRadius = feedPersonImageView.frame.size.width / 2
        }
    }
    @IBOutlet weak var feedPersonName: UILabel!
    @IBOutlet weak var feedTime: UILabel!
    @IBOutlet weak var feedDriveImage: UIImageView!

    @IBOutlet weak var feedCommentIcon: UIButton!
    @IBOutlet weak var feedCommentsCount: UIButton!
    
    @IBOutlet weak var feedLikeIcon: UIButton!
    @IBOutlet weak var feedLikeCount: UIButton!
    @IBOutlet weak var feedTitle: UIButton!
    
    @IBOutlet weak var feedCommentImageView: UIImageView! {
        didSet {
            feedCommentImageView.layer.cornerRadius = feedCommentImageView.frame.size.width / 2
        }
    }
    @IBOutlet weak var feedCommentName: UILabel!
    @IBOutlet weak var feedCommentText: UILabel!
    @IBOutlet weak var feedCommentTime: UILabel!
    
    @IBOutlet weak var feedPlayButton: UIButton! {
        didSet {
            feedPlayButton.layer.cornerRadius = feedPlayButton.frame.size.width / 2
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
