//
//  CommentsViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/18/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
class CommentsViewController: UIViewController, UITextFieldDelegate, layoutSubViewDelegate{
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var driveImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var commentAccessoryView: UIView!
    @IBOutlet weak var viewTypeCommnet: UIView!

    @IBOutlet weak var btnAddComment: UIBarButtonItem!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var webViewBottmContraint: NSLayoutConstraint!


    var isReply: Int = 0
    var replyid: Int = 0
    var driverid: Int = 0
    var commentArray = NSMutableArray.init()
    var trackid : Int = 0
    var driveid : Int = 0
    var isdrive : Bool = true
    var dict: NSDictionary?
    // MARK: Variables
    var model = UserModel.shared
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "CommentParentTableViewCell", bundle: nil), forCellReuseIdentifier: "parentcell")
        self.tableView.register(UINib(nibName: "CommentReplyTableViewCell", bundle: nil), forCellReuseIdentifier: "childcell")
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: UITextfieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Helper Methods
    func initViews() {
        tableView.tableFooterView = UIView()
        playButton.layer.cornerRadius = 50 / 2
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = .black
        callDriveCommentAPI()
        if (dict?.object(forKey: "thumb_image") as! String) == "" {
            driveImageView.setImageWith(NSURL(string: dict?.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            webView.isHidden = true
            playButton.isHidden = true
        }else{
            driveImageView.setImageWith(NSURL(string: dict?.object(forKey: "thumb_image") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            playButton.isHidden = true
        }
        if let videolink = dict?.object(forKey: "videolink") {
            if (videolink as! String) != "" {
                let request = URLRequest(url: URL(string:videolink as! String)!)
                webView.loadRequest(request)
            }
        }
        viewTypeCommnet.isHidden = true
    }
    // MARK: API Calls
    func callTrackCommentAPI() {
        let app = UIApplication.shared.delegate as! AppDelegate
        trackid = app.trackid
        let params = [
            URLConstant.Param.TAG: "getcomment",
            "track_id": trackid
            ] as [String : Any]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_TRACKCOMMENTS, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.commentField.text = ""
                    self.commentArray = (json.object(forKey: "comments") as! NSArray).mutableCopy() as! NSMutableArray
                    self.tableView.reloadData()
                    //                    UIUtil.scrollToBottomRow(count: 10, tableView: self.tableView)
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    // MARK: API Calls
    func callAddTrackCommentAPI() {
        if commentField.text! as String == "" {
            return
        }
        let app = UIApplication.shared.delegate as! AppDelegate
        trackid = app.trackid
        let userid = model.userid()
        let params = [
            URLConstant.Param.TAG: "addtrackcomment",
            "track_id": trackid,
            "creator_id": userid ,
            "comment": (commentField.text! as String)
            ] as [String : Any]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.ADD_TRACKCOMMENTS, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    self.callTrackCommentAPI()
                    self.view.endEditing(true)
               }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    // MARK: API Calls
    func callDriveCommentAPI() {
//        let app = UIApplication.shared.delegate as! AppDelegate
        let params = [
            URLConstant.Param.TAG: "getcomment",
            "drive_id": driveid
            ] as [String : Any]
        UIUtil.showProcessing(message: "Loading...")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_DRIVECOMMENTS, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.commentField.text = ""
                    self.commentArray = (json.object(forKey: "comments") as! NSArray).mutableCopy() as! NSMutableArray
                    self.tableView.reloadData()
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    // MARK: API Calls
    func callAddDriveCommentAPI() {
        if commentField.text! as String == "" {
            return
        }
        let userid = model.userid()
        var params: [String: Any]
        if self.isReply == 0 {
            params = [
                URLConstant.Param.TAG: "comment",
                "drive_id": driveid,
                "driver_id": userid,
                "comment": (commentField.text! as String)
                ] as [String : Any]
        }else {
            params = [
                URLConstant.Param.TAG: "comment",
                "drive_id": driveid,
                "driver_id": userid,
                "reply" : 1,
                "reply_id" : self.replyid,
                "reply_user" : self.driverid,
                "comment": (commentField.text! as String)
                ] as [String : Any]
        }
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.ADD_DRIVECOMMENTS, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    self.callDriveCommentAPI()
                    self.view.endEditing(true)
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
    // MARK: IBActions
    @IBAction func playClick(_ sender: Any) {
    }
    
    @IBAction func sendClick(_ sender: Any) {
        self.viewTypeCommnet.isHidden = true
        if isdrive == true {
            callAddDriveCommentAPI()
        }else{
            callAddTrackCommentAPI()
        }
    }
    
    @IBAction func AddCommentAction(_ sender: Any) {
        self.isReply = 0
        self.viewTypeCommnet.isHidden = false
    }

    func replyClick(_ sender: UIButton) {
        self.isReply = 1
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let dict = commentArray.object(at: (indexPath?.row)!) as! NSDictionary
        self.replyid = Int(dict.object(forKey: "comment_id") as! String)!
        self.driverid = Int(dict.object(forKey: "driver_id") as! String)!
        self.viewTypeCommnet.isHidden = false
    }

    func showRepliesClick(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let dict = commentArray.object(at: (indexPath?.row)!) as! NSDictionary
        let commentid = Int(dict.object(forKey: "comment_id") as! String)
        let cell = self.tableView.cellForRow(at: indexPath!) as! CommentParentTableViewCell
        let params = [
            URLConstant.Param.TAG: "getReplies",
            "drive_id": driveid,
            "comment_id": commentid!
            ] as [String : Any]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_DRIVECOMMENTS, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.commentField.text = ""
                    self.viewTypeCommnet.isHidden = true
                    let replycomments = (json.object(forKey: "comments") as! NSArray).mutableCopy() as! NSMutableArray
                    cell.setDataSource(replycomments)

//                    self.tableView.reloadData()
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }

    }

    func updateTableview() {
        self.tableView.layoutIfNeeded()
        
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if commentArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Comment Found"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parentcell", for: indexPath) as! CommentParentTableViewCell
        let dict = commentArray.object(at: indexPath.row) as! NSDictionary
        cell.commentName.text = dict.object(forKey: "creatorname") as? String
        cell.commentText.text = dict.object(forKey: "comment") as? String
        cell.commentTime.text = (dict.object(forKey: "created_date") as? String)?.FeedDate()
        cell.btnReply.addTarget(self, action: #selector(CommentsViewController.replyClick(_:)), for: .touchUpInside)
        cell.btnShowReplies.addTarget(self, action: #selector(CommentsViewController.showRepliesClick(_:)), for: .touchUpInside)
        if (dict.object(forKey: "hasreply") as! Int) > 0{
            cell.btnShowReplies.isHidden = false
        }else{
            cell.btnShowReplies.isHidden = true
        }
        if (URL(string: dict.object(forKey: "creatorphoto") as! String) != nil) {
            cell.commentImageView.setImageWith(URL(string: dict.object(forKey: "creatorphoto") as! String)!, placeholderImage: #imageLiteral(resourceName: "person-avatar"))
        }else{
            cell.commentImageView.image = #imageLiteral(resourceName: "person-avatar")
        }
        cell.selectionStyle = .none
        cell.delegate1 = self

        return cell
    }
    
}

