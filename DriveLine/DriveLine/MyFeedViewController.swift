//
//  MyFeedViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import UILoadControl
import INTULocationManager
import MobileCoreServices

class MyFeedViewController: UIViewController, UIScrollViewDelegate {

    let VIDEO_IDENTIFIER = "VIDEO_IDENTIFIER"
    let COMMENTS_IDENTIFIER = "COMMENTS_IDENTIFIER"
    let COMMENTS_DRIVE = "COMMENTS_DRIVE"
    let GOTO_DETAIL = "GOTO_DRIVE_DETAIL"
    let TAKEME = "TAKE_ME_START"
    var trackArray = NSMutableArray.init()
    var globalFeedArray = NSMutableArray.init()
    var myFeedArray = NSMutableArray.init()
    let locationManager = INTULocationManager.sharedInstance()
    var locationRequestId = INTULocationRequestID()
    var page = 1
    var mypage = 1
    var snapImage: UIImage!
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myTableView: UITableView!

    var model = UserModel.shared
    var videoLink:String = ""
    let app = UIApplication.shared.delegate as! AppDelegate
    var selectedIndex = 0
    // MARK: Variables
    
    @IBOutlet weak var setFeed: UISegmentedControl!
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "feedCell")
        self.myTableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "feedCell")
        initViews()
        self.setFeed.selectedSegmentIndex = 0
        self.tableView.isHidden = false
        self.myTableView.isHidden = true

        if ModelManager.getInstance().getAllDriveData().count > 0 {
            if !SharedAppDelegate.uploadTimer.isValid {
                SharedAppDelegate.setTimer()
            }
        }
    }
    
    // MARK: Helper Methods
    func initViews() {
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        tableView.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
        tableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        myTableView.loadControl = UILoadControl(target: self, action: #selector(loadMyMore(sender:)))
        myTableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(loadRecent(sender:)), for:
                .valueChanged)
            self.tableView.refreshControl?.beginRefreshing()
            myTableView.refreshControl = UIRefreshControl()
            myTableView.refreshControl?.addTarget(self, action: #selector(loadMyRecent(sender:)), for:
                .valueChanged)
            self.myTableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }

        if model.userbadge() != 0 {
            (self.tabBarController?.tabBar.items?[3])?.badgeValue = "\(model.userbadge())"
            if #available(iOS 10.0, *) {
                (self.tabBarController?.tabBar.items?[3])?.badgeColor = .red
            } else {
                // Fallback on earlier versions
            }
        }else{
            (self.tabBarController?.tabBar.items?[3])?.badgeValue = ""
            if #available(iOS 10.0, *) {
                (self.tabBarController?.tabBar.items?[3])?.badgeColor = .clear
            } else {
                // Fallback on earlier versions
            }

        }
        getCurrentLocation()
    }
        //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }

    //load more tableView data
    func loadMore(sender: AnyObject?) {
        callTrackshowAPI(page)
    }
    func loadMyMore(sender: AnyObject?) {
        callMyFeedshowAPI(mypage)
    }
    func loadRecent(sender: AnyObject?) {
        page = 1
        callTrackshowAPI(1)
    }
    func loadMyRecent(sender: AnyObject?) {
        mypage = 1
        callMyFeedshowAPI(1)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        initViews()
    }

    func commentsClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = trackArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: COMMENTS_IDENTIFIER, sender: self)
    }

    func commentsMyClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
        let indexPath = myTableView.indexPathForRow(at: buttonPosition)
        let dict = myFeedArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: COMMENTS_IDENTIFIER, sender: self)
    }

    @IBAction func onSelectFeed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.tableView.isHidden = false
            if trackArray.count == 0 {
                callTrackshowAPI(self.page)
            }
            self.myTableView.isHidden = true

        }else{
            self.myTableView.isHidden = false
            if myFeedArray.count == 0 {
                callMyFeedshowAPI(self.mypage)
            }
            self.tableView.isHidden = true

        }
    }

    func driveItClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = trackArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: TAKEME, sender: self)
    }

    func driveItMyClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
        let indexPath = myTableView.indexPathForRow(at: buttonPosition)
        let dict = myFeedArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: TAKEME, sender: self)
    }

    func callShareApi() {

        let params = [
            URLConstant.Param.TAG: "share",
            "creator_id" : self.model.userid()
            ] as [String : String]
        print (params)
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.SHARE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }

    }

    func callShareMyApi() {

        let params = [
            URLConstant.Param.TAG: "share",
            "creator_id" : self.model.userid()
            ] as [String : String]
        print (params)
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.SHARE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }

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
            }else if identifier == TAKEME {
                if let dvc = segue.destination as? DriveMapStartViewController {
                    dvc.driveid = app.driveid
                    dvc.myDrive = (trackArray.object(at: selectedIndex) as? NSDictionary)!
                }
            }else if identifier == "FeedToOtherUserProfile" {
                if let dvc = segue.destination as? OtherUserProfileViewController {
                    if self.setFeed.selectedSegmentIndex == 0 {
                        let dict = trackArray.object(at: selectedIndex) as! NSDictionary
                        dvc.otheruserid = dict.object(forKey: "creator_id") as! String
                    }else{
                        let dict = myFeedArray.object(at: selectedIndex) as! NSDictionary
                        dvc.otheruserid = dict.object(forKey: "creator_id") as! String
                    }
                }
            }
        }
    }

    func likesClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = trackArray.object(at: (indexPath?.row)!) as! NSDictionary
        self.tableView.isUserInteractionEnabled = false
        let cell = self.tableView.cellForRow(at: indexPath!) as! FeedTableViewCell
        cell.imvLike.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1.0,
                       delay: 0.5,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: .curveLinear,
                       animations: {
                        cell.imvLike.transform = CGAffineTransform.identity
        },
                       completion: nil
        )

        let params = [
            URLConstant.Param.TAG: "like",
            "creator_id": model.userid(),
            "drive_id": String((dict.object(forKey: "driveid") as! NSString).intValue)
            ] as [String : String]
        WebserviceUtil.callPost(httpRequest: URLConstant.API.ADD_DRIVELIKE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    if json.object(forKey: "like") as! String == "like"{
                        let cell = self.tableView.cellForRow(at: indexPath!) as! FeedTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count + 1
                        cell.lblLikeCount.text = "\(count)"
                        cell.imvLike.image = #imageLiteral(resourceName: "ic_like_blue")
                        let mdict = dict.mutableCopy() as! NSMutableDictionary
                        mdict["like_count"] = "\(count)"
                        mdict["userlike"] = "1"
                        self.trackArray.removeObject(at: (indexPath?.row)!)
                        self.trackArray.insert(mdict, at: (indexPath?.row)!)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }else{
                        let cell = self.tableView.cellForRow(at: indexPath!) as! FeedTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count - 1
                        cell.lblLikeCount.text = "\(count)"
                        cell.imvLike.image = #imageLiteral(resourceName: "ic_like_dark")
                        let mdict = dict.mutableCopy() as! NSMutableDictionary
                        mdict["like_count"] = "\(count)"
                        mdict["userlike"] = "0"
                        self.trackArray.removeObject(at: (indexPath?.row)!)
                        self.trackArray.insert(mdict, at: (indexPath?.row)!)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
                self.tableView.isUserInteractionEnabled = true
            }
        }) { (error) in
            self.tableView.isUserInteractionEnabled = true
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    func likesMyClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
        let indexPath = myTableView.indexPathForRow(at: buttonPosition)
        let dict = myFeedArray.object(at: (indexPath?.row)!) as! NSDictionary
        self.myTableView.isUserInteractionEnabled = false
        let cell = self.myTableView.cellForRow(at: indexPath!) as! FeedTableViewCell
        cell.imvLike.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1.0,
                       delay: 0.5,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: .curveLinear,
                       animations: {
                        cell.imvLike.transform = CGAffineTransform.identity
        },
                       completion: nil
        )

        let params = [
            URLConstant.Param.TAG: "like",
            "creator_id": model.userid(),
            "drive_id": String((dict.object(forKey: "driveid") as! NSString).intValue)
            ] as [String : String]
        WebserviceUtil.callPost(httpRequest: URLConstant.API.ADD_DRIVELIKE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    if json.object(forKey: "like") as! String == "like"{
                        let cell = self.myTableView.cellForRow(at: indexPath!) as! FeedTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count + 1
                        cell.lblLikeCount.text = "\(count)"
                        cell.imvLike.image = #imageLiteral(resourceName: "ic_like_blue")
                        let mdict = dict.mutableCopy() as! NSMutableDictionary
                        mdict["like_count"] = "\(count)"
                        mdict["userlike"] = "1"
                        self.myFeedArray.removeObject(at: (indexPath?.row)!)
                        self.myFeedArray.insert(mdict, at: (indexPath?.row)!)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }else{
                        let cell = self.myTableView.cellForRow(at: indexPath!) as! FeedTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count - 1
                        cell.imvLike.image = #imageLiteral(resourceName: "ic_like_dark")
                        cell.lblLikeCount.text = "\(count)"
                        let mdict = dict.mutableCopy() as! NSMutableDictionary
                        mdict["like_count"] = "\(count)"
                        mdict["userlike"] = "0"
                        self.myFeedArray.removeObject(at: (indexPath?.row)!)
                        self.myFeedArray.insert(mdict, at: (indexPath?.row)!)
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
                self.myTableView.isUserInteractionEnabled = true
            }
        }) { (error) in
            self.myTableView.isUserInteractionEnabled = true
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    func playClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = trackArray.object(at: (indexPath?.row)!) as! NSDictionary
        videoLink = (dict.object(forKey: "videolink") as! String?)!
        if videoLink != ""{
            performSegue(withIdentifier: VIDEO_IDENTIFIER, sender: self)
        }
    }

    func playMyClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
        let indexPath = myTableView.indexPathForRow(at: buttonPosition)
        let dict = myFeedArray.object(at: (indexPath?.row)!) as! NSDictionary
        videoLink = (dict.object(forKey: "videolink") as! String?)!
        if videoLink != ""{
            performSegue(withIdentifier: VIDEO_IDENTIFIER, sender: self)
        }
    }

    // MARK: IBActions
    
    // MARK: API Calls
    func callTrackshowAPI(_ pageNumber: Int) {
        let params = [
            URLConstant.Param.TAG: "showmydrive",
            "user_id": model.userid(),
            URLConstant.Param.PAGE: pageNumber
            ] as [String : Any]
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYDRIVE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
//                    print(json)
                    if self.page == 1 {
                        self.trackArray = NSMutableArray.init()
                    }
                    let drives = (json.object(forKey: "all_drive") as! NSArray).mutableCopy() as! NSMutableArray
                    if (drives.count < 10) {
                    }else {
                        self.page = self.page + 1
                    }
                    let nDriveArray = self.trackArray.mutableCopy() as! NSMutableArray
                    nDriveArray.addObjects(from: drives as! [Any])

                    self.trackArray = nDriveArray//self.trackArray.adding(drives) as! NSMutableArray
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
            }
        }) { (error) in
            UIUtil.hideProcessing()
            self.tableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl?.endRefreshing()
            } else {
                // Fallback on earlier versions
            }
            self.tableView.reloadData()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }

    // MARK: API Calls
    func callMyFeedshowAPI(_ pageNumber: Int) {
        let params = [
            URLConstant.Param.TAG: "showmyfeed",
            URLConstant.Param.PAGE: pageNumber,
            "user_id": model.userid()
            ] as [String : Any]
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYDRIVE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
//                    print(json)
                    if self.mypage == 1 {
                        self.myFeedArray = NSMutableArray.init()
                    }
                    let drives = (json.object(forKey: "all_drive") as! NSArray).mutableCopy() as! NSMutableArray
                    if (drives.count < 10) {
                    }else {
                        self.mypage = self.mypage + 1
                    }
                    let nDriveArray = self.myFeedArray.mutableCopy() as! NSMutableArray
                    nDriveArray.addObjects(from: drives as! [Any])

                    self.myFeedArray = nDriveArray//self.trackArray.adding(drives) as! NSMutableArray
                    self.myTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myTableView.reloadData()
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    self.myTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myTableView.reloadData()
                }
                //                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            self.myTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
            if #available(iOS 10.0, *) {
                self.myTableView.refreshControl?.endRefreshing()
            } else {
                // Fallback on earlier versions
            }
            self.myTableView.reloadData()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }

    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    SharedAppDelegate.lat = location!.coordinate.latitude
                    SharedAppDelegate.lng = location!.coordinate.longitude
                    self.callTrackshowAPI(self.page)
                }
                break
            case .error:
                UIUtil.showToast(message: "Unable to get current location")
                self.callTrackshowAPI(self.page)

                break
            default:
                break
            }
        }
    }

    func shareClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = trackArray.object(at: (indexPath?.row)!) as! NSDictionary
        let snimage = self.tableView.snapshotRows(at: [indexPath!])!

        if let myWebsite = NSURL(string: dict["videolink"] as! String) {
            if myWebsite.absoluteString != "" {
                let textToShare = "This is my awaresome drive!  Check out this youtube url about it!"
                let objectsToShare = [textToShare as AnyObject, myWebsite, snimage as AnyObject] as [AnyObject]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                self.present(activityVC, animated: true, completion: nil)
                activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                    if completed == true {
                        self.callShareApi()
                        print("Saved")
                    }
                }
            }else{
                let textToShare = "This is my awaresome drive!"
                let objectsToShare = [textToShare, snimage] as [AnyObject]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                self.present(activityVC, animated: true, completion: nil)
                activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                    if completed == true {
                        self.callShareApi()
                        print("Saved")
                    }
                }
            }
        }else{
            let textToShare = "This is my awaresome drive!"
            let objectsToShare = [textToShare, snimage] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            self.present(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                if completed == true {
                    self.callShareApi()
                    print("Saved")
                }
            }
        }

    }

    func shareMyClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
        let indexPath = myTableView.indexPathForRow(at: buttonPosition)
        let dict = myFeedArray.object(at: (indexPath?.row)!) as! NSDictionary
        let snimage = self.myTableView.snapshotRows(at: [indexPath!])!

        if let myWebsite = NSURL(string: dict["videolink"] as! String) {
            let textToShare = "This is my awaresome drive!  Check out this youtube url about it!"
            let objectsToShare = [textToShare as AnyObject, myWebsite, snimage as AnyObject] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            self.present(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                if completed == true {
                    self.callShareMyApi()
                    print("Saved")
                }
            }
        }else{
            let textToShare = "This is my awaresome drive!"
            let objectsToShare = [textToShare, snimage] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            self.present(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                if completed == true {
                    self.callShareMyApi()
                    print("Saved")
                }
            }
        }

    }
    func otherUserProfile(_ sender: UIButton) {

        if self.setFeed.selectedSegmentIndex == 0 {
            let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
            let indexPath = tableView.indexPathForRow(at: buttonPosition)
            //        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
            selectedIndex = (indexPath?.row)!
            let dict = trackArray.object(at: selectedIndex) as! NSDictionary
            if (dict.object(forKey: "creator_id") as! String) == model.userid() {
                self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
                self.tabBarController?.selectedIndex = 4
            }else{
                performSegue(withIdentifier: "FeedToOtherUserProfile", sender: self)
            }
        }else{
            let buttonPosition = sender.convert(CGPoint(), to: self.myTableView)
            let indexPath = myTableView.indexPathForRow(at: buttonPosition)
            //        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
            selectedIndex = (indexPath?.row)!
            let dict = myFeedArray.object(at: selectedIndex) as! NSDictionary
            if (dict.object(forKey: "creator_id") as! String) == model.userid() {
                self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
                self.tabBarController?.selectedIndex = 4
            }else{
                performSegue(withIdentifier: "FeedToOtherUserProfile", sender: self)
            }
        }
    }

}

extension MyFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if tableView == self.tableView {
            if trackArray.count > 0
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }else{
            if myFeedArray.count > 0
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return (trackArray.count)
        }else{
            return (myFeedArray.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell
        if tableView == self.tableView {
            let dict = trackArray.object(at: indexPath.row) as! NSDictionary

            // Setting Up Comments Click
            cell.btnComment.addTarget(self, action: #selector(MyFeedViewController.commentsClick(sender:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(MyFeedViewController.likesClick(sender:)), for: .touchUpInside)
            cell.btnDrive.addTarget(self, action: #selector(MyFeedViewController.driveItClick(sender:)), for: .touchUpInside)
            cell.btnShare.addTarget(self, action: #selector(MyFeedViewController.shareClick(sender:)), for: .touchUpInside)
            cell.btnOtherUserProfile.addTarget(self, action: #selector(MyFeedViewController.otherUserProfile(_ :)), for: .touchUpInside)
            // Settings Up Play Click
            cell.btnPlayVideo.addTarget(self, action: #selector(MyFeedViewController.playClick(sender:)), for: .touchUpInside)
            if URL(string: dict.object(forKey: "creatorphoto") as! String) != nil{
                cell.imvUserAvatar.setImageWith(URL(string: dict.object(forKey: "creatorphoto") as! String)!, placeholderImage: #imageLiteral(resourceName: "person-avatar"))
            }else{
                cell.imvUserAvatar.image = #imageLiteral(resourceName: "person-avatar")
            }
            cell.lblUserName.text = dict.object(forKey: "creatorname") as! String?
            if (dict.object(forKey: "thumb_image") as! String) == "" {
                cell.imvMap.setImageWith(NSURL(string: dict.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
                cell.btnPlayVideo.isHidden = true
            }else{
                cell.imvMap.setImageWith(NSURL(string: dict.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
                cell.btnPlayVideo.isHidden = false
            }
            if (dict.object(forKey: "userlike") as! String) == "1" {
                cell.imvLike.image = #imageLiteral(resourceName: "ic_like_blue")
            }else{
                cell.imvLike.image = #imageLiteral(resourceName: "ic_like_dark")
            }
            cell.lblDate.text = (dict.object(forKey: "createdate") as? String)?.FeedDate()
            cell.lblCommentCount.text = (dict.object(forKey: "comment_count") as? String)!
            cell.lblLikeCount.text = (dict.object(forKey: "like_count") as? String)!
            cell.lblDriveTitle.text = (dict["drivename"] as? String)
            cell.lblPoint.text = (dict["creatorpoints"] as? String)!+" points"
            let length = Float((dict["waylength"] as? String)!)! / 1609.0
            cell.lblLength.text = "Length: "+String(format: "%.3f miles", length)
            cell.lblTime.text = "Time: "+getElapsTime(dict["starttime"] as! String, dict["endtime"] as! String)
            cell.lblStyle.text = "Style: "+(dict["screentype"] as? String)!
            let firstPoint = CLLocation(latitude: SharedAppDelegate.lat, longitude: SharedAppDelegate.lng)
            let secondPoint = CLLocation(latitude: Double(dict["startlat"] as! String)!, longitude: Double(dict["startlng"] as! String)!)
            let distancehere = firstPoint.distance(from: secondPoint) / 1609
            cell.lblToStart.text = "To Start: "+String(Int(distancehere))+" miles"
            cell.driveId = indexPath.row

            cell.selectionStyle = .none
            return cell
        }else
        {
            let dict = myFeedArray.object(at: indexPath.row) as! NSDictionary

            // Setting Up Comments Click
            cell.btnComment.addTarget(self, action: #selector(MyFeedViewController.commentsMyClick(sender:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(MyFeedViewController.likesMyClick(sender:)), for: .touchUpInside)
            cell.btnDrive.addTarget(self, action: #selector(MyFeedViewController.driveItMyClick(sender:)), for: .touchUpInside)
            cell.btnShare.addTarget(self, action: #selector(MyFeedViewController.shareMyClick(sender:)), for: .touchUpInside)
            cell.btnOtherUserProfile.addTarget(self, action: #selector(MyFeedViewController.otherUserProfile(_ :)), for: .touchUpInside)

            // Settings Up Play Click
            cell.btnPlayVideo.addTarget(self, action: #selector(MyFeedViewController.playMyClick(sender:)), for: .touchUpInside)
            if URL(string: dict.object(forKey: "creatorphoto") as! String) != nil{
                cell.imvUserAvatar.setImageWith(URL(string: dict.object(forKey: "creatorphoto") as! String)!, placeholderImage: #imageLiteral(resourceName: "person-avatar"))
            }else{
                cell.imvUserAvatar.image = #imageLiteral(resourceName: "person-avatar")
            }
            cell.lblUserName.text = dict.object(forKey: "creatorname") as! String?
            if (dict.object(forKey: "thumb_image") as! String) == "" {
                cell.imvMap.setImageWith(NSURL(string: dict.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
                cell.btnPlayVideo.isHidden = true
            }else{
                cell.imvMap.setImageWith(NSURL(string: dict.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
                cell.btnPlayVideo.isHidden = false
            }
            if (dict.object(forKey: "userlike") as! String) == "1" {
                cell.imvLike.image = #imageLiteral(resourceName: "ic_like_blue")
            }else{
                cell.imvLike.image = #imageLiteral(resourceName: "ic_like_dark")
            }
            cell.lblDate.text = (dict.object(forKey: "createdate") as? String)?.FeedDate()
            cell.lblCommentCount.text = (dict.object(forKey: "comment_count") as? String)!
            cell.lblLikeCount.text = (dict.object(forKey: "like_count") as? String)!
            cell.lblDriveTitle.text = (dict["drivename"] as? String)
            cell.lblPoint.text = (dict["creatorpoints"] as? String)!+" points"
            let length = Float((dict["waylength"] as? String)!)! / 1609.0
            cell.lblLength.text = "Length: "+String(format: "%.3f miles", length)
            cell.lblTime.text = "Time: "+getElapsTime(dict["starttime"] as! String, dict["endtime"] as! String)
            cell.lblStyle.text = "Style: "+(dict["screentype"] as? String)!
            let firstPoint = CLLocation(latitude: SharedAppDelegate.lat, longitude: SharedAppDelegate.lng)
            let secondPoint = CLLocation(latitude: Double(dict["startlat"] as! String)!, longitude: Double(dict["startlng"] as! String)!)
            let distancehere = firstPoint.distance(from: secondPoint) / 1609
            cell.lblToStart.text = "To Start: "+String(Int(distancehere))+" miles"
            cell.driveId = indexPath.row

            cell.selectionStyle = .none
            return cell
        }
    }

    func getElapsTime(_ starttime: String, _ endtime: String) -> String {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let startDate = formatter.date(from: starttime)
        let endDate = formatter.date(from: endtime)
        var timeinterval = endDate?.timeIntervalSince(startDate!)
        if timeinterval == nil{
            timeinterval = 0
        }
        return stringFromTimeInterval(interval: timeinterval!) as String
    }

    func stringFromTimeInterval(interval: TimeInterval) -> NSString {


        let seconds = interval.truncatingRemainder(dividingBy: 60)
        let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
        let hours = (interval / 3600)

        return NSString(format: "%0.2d:%0.2d:%0.2d", Int(hours), Int(minutes), Int(seconds))
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.75
    }
}
extension UITableView
{
    func snapshotRows(at indexPaths: Set<IndexPath>) -> UIImage?
    {
        guard !indexPaths.isEmpty else { return nil }
        var rect = self.rectForRow(at: indexPaths.first!)
        for indexPath in indexPaths
        {
            let cellRect = self.rectForRow(at: indexPath)
            rect = rect.union(cellRect)
        }

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        for indexPath in indexPaths
        {
            let cell = self.cellForRow(at: indexPath)
            cell?.layer.bounds.origin.y = self.rectForRow(at: indexPath).origin.y - rect.minY
            cell?.layer.render(in: context)
            cell?.layer.bounds.origin.y = 0
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
