//
//  CommentParentTableViewCell.swift
//  DriveLine
//
//  Created by mac on 2017-11-08.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
@objc protocol layoutSubViewDelegate{
    @objc optional func updateTableview()
}

class CommentParentTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyCommentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childcell", for:indexPath as IndexPath) as! CommentReplyTableViewCell
        cell.commentText.text = "this is the subcomment"
        return cell
    }

    var delegate1: layoutSubViewDelegate?
    var replyCommentArray: NSMutableArray!

    @IBOutlet weak var subTableView: UITableView!
    @IBOutlet weak var subTableViewHeight: NSLayoutConstraint!
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
        self.replyCommentArray = NSMutableArray.init()
        setUpTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpTable(){
        subTableView.register(UINib(nibName: "CommentReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "childcell")
        subTableView?.delegate = self
        subTableView?.dataSource = self
        subTableView.estimatedRowHeight = 60
        subTableView.rowHeight = UITableViewAutomaticDimension
    }

    func setDataSource(_ data : NSMutableArray) {
        self.replyCommentArray = data
        self.subTableView.reloadData()
        self.subTableView.layoutSubviews()
        self.layoutSubviews()

    }
    override func layoutSubviews() {
        super.layoutSubviews()

        let tbsize = subTableView.contentSize
        let tbframe = subTableView.frame
        let frame = CGRect(x: tbframe.origin.x, y: tbframe.origin.y, width: tbframe.size.width, height: tbsize.height)
        subTableView.frame = frame
        if delegate1 != nil {
            self.delegate1?.updateTableview!()
        }
//        subTableView?.frame = CGRect(0.2, 0.3, self.bounds.size.width-5, self.bounds.size.height-5)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
