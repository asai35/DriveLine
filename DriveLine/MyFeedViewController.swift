//
//  MyFeedViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import UILoadControl

class MyFeedViewController: UIViewController, UIScrollViewDelegate {

    let VIDEO_IDENTIFIER = "VIDEO_IDENTIFIER"
    let COMMENTS_IDENTIFIER = "COMMENTS_IDENTIFIER"
    let COMMENTS_DRIVE = "COMMENTS_DRIVE"
    var trackArray = NSMutableArray.init()
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    var model = UserModel.shared
    var videoLink:String = ""
    let app = UIApplication.shared.delegate as! AppDelegate
    var selectedIndex = 0
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        tableView.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        tableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.addTarget(self, action: #selector(loadRecent(sender:)), for:
                .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        callTrackshowAPI()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }
    }
        //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }

    //load more tableView data
    func loadMore(sender: AnyObject?) {
        callTrackshowAPI()
    }
    func loadRecent(sender: AnyObject?) {
        callTrackshowAPI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        initViews()
    }
    
    func commentsClick(sender: UIButton) {
        var index = sender.tag - 1000
        if index >= 1000{
            index = index - 1000
        }
        let dict = trackArray.object(at: index) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = index
        performSegue(withIdentifier: COMMENTS_IDENTIFIER, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == COMMENTS_IDENTIFIER {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.isdrive = true
                    dvc.driveid = app.driveid
                    dvc.dict = trackArray.object(at: selectedIndex) as? NSDictionary
                }
            }else if identifier == VIDEO_IDENTIFIER {
                if let dvc = segue.destination as? VideoViewController {
                    dvc.link = self.videoLink
                }
            }
        }
    }

    func likesClick(sender: UIButton) {
        var index = sender.tag - 3000
        if index >= 1000{
            index = index - 1000
        }
        let dict = trackArray.object(at: index) as! NSDictionary
        let params = [
            URLConstant.Param.TAG: "like",
            "creator_id": model.userid(),
            "drive_id": String((dict.object(forKey: "driveid") as! NSString).intValue)
            ] as [String : String]
//        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.ADD_DRIVELIKE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    if json.object(forKey: "like") as! String == "like"{
                        let button = sender.superview?.viewWithTag(index + 4000) as! UIButton
                        var count = Int(button.currentTitle!.replacingOccurrences(of: " likes", with: ""))! as Int
                        count = count + 1
                        button.setTitle("\(count) likes", for: UIControlState.normal)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }else{
                        let button = sender.superview?.viewWithTag(index + 4000) as! UIButton
                        var count = Int(button.currentTitle!.replacingOccurrences(of: " likes", with: ""))! as Int
                        count = count - 1
                        button.setTitle("\(count) likes", for: UIControlState.normal)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }
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
    
    func playClick(sender: UIButton) {
        let index = sender.tag - 5000
        let dict = trackArray.object(at: index) as! NSDictionary
        videoLink = (dict.object(forKey: "videolink") as! String?)!
        if videoLink != ""{
            performSegue(withIdentifier: VIDEO_IDENTIFIER, sender: self)
        }
    }
    
    // MARK: IBActions
    
    // MARK: API Calls
    func callTrackshowAPI() {
        let params = [
            URLConstant.Param.TAG: "showmydrive"
        ]
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYDRIVE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.trackArray = (json.object(forKey: "all_drive") as! NSArray).mutableCopy() as! NSMutableArray
                    self.tableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.tableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.tableView.reloadData()
               }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    self.tableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.tableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.tableView.reloadData()
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

}

extension MyFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if trackArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (trackArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyFeedCell
        let dict = trackArray.object(at: indexPath.row) as! NSDictionary
        
        // Setting Up Comments Click
        cell.feedCommentIcon.addTarget(self, action: #selector(MyFeedViewController.commentsClick(sender:)), for: .touchUpInside)
        cell.feedCommentIcon.tag = indexPath.row+1000
        cell.feedCommentsCount.addTarget(self, action: #selector(MyFeedViewController.commentsClick(sender:)), for: .touchUpInside)
        cell.feedCommentsCount.tag = indexPath.row+2000
        cell.feedLikeCount.addTarget(self, action: #selector(MyFeedViewController.likesClick(sender:)), for: .touchUpInside)
        cell.feedLikeCount.tag = indexPath.row+4000
        cell.feedLikeIcon.addTarget(self, action: #selector(MyFeedViewController.likesClick(sender:)), for: .touchUpInside)
        cell.feedLikeIcon.tag = indexPath.row+3000
        
        // Settings Up Play Click
        cell.feedPlayButton.addTarget(self, action: #selector(MyFeedViewController.playClick(sender:)), for: .touchUpInside)
        cell.feedPlayButton.tag = indexPath.row+5000
        
        cell.feedPersonName.text = dict.object(forKey: "creatorname") as! String?
        if (dict.object(forKey: "thumb_image") as! String) == "" {
            cell.feedDriveImage.setImageWith(NSURL(string: dict.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            cell.feedPlayButton.isHidden = true
        }else{
            cell.feedDriveImage.setImageWith(NSURL(string: dict.object(forKey: "thumb_image") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            cell.feedPlayButton.isHidden = false
        }
        cell.feedTime.text = (dict.object(forKey: "createdate") as? String)?.FeedDate()
        cell.feedCommentsCount.setTitle((dict.object(forKey: "comment_count") as? String)!+" comments", for: UIControlState.normal)
        cell.feedLikeCount.setTitle((dict.object(forKey: "like_count") as? String)!+" likes", for: UIControlState.normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
}
