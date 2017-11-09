//
//  CommentReplyTableViewCell.swift
//  DriveLine
//
//  Created by mac on 2017-11-08.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class CommentReplyTableViewCell: UITableViewCell {

    @IBOutlet weak var commentImageView: UIImageView! {
        didSet {
            commentImageView.layer.cornerRadius = commentImageView.frame.size.width / 2
        }
    }
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var commentText: UILabel!

    @IBOutlet weak var btnShowReplies: UIButton!
    @IBOutlet weak var btnReply: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
