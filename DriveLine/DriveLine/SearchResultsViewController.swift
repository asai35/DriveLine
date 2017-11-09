//
//  SearchResultsViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/20/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import MapKit
import INTULocationManager
import MobileCoreServices
import UILoadControl
class SearchResultsViewController: UIViewController {
    
    let DRIVE_DETAIL_IDENTIFIER = "DRIVE_DETAIL"
    var distance: String?
    var driveType : String?
    let locationManager = INTULocationManager.sharedInstance()
    var locationRequestId = INTULocationRequestID()
    var coordinatesList = [CLLocation]()
    var appDelegate: AppDelegate?
    var latitude = 0.0
    var longitude = 0.0
    var myDrive : NSDictionary?
    var searchresultArray: NSMutableArray = []
    var model = UserModel.shared
    let app = UIApplication.shared.delegate as! AppDelegate
    var selectedIndex = 0
    var videoLink: String = ""
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
        self.tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "feedCell")
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
//        UIUtil.showProcessing(message: "Please wait")
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate = delegate
        }
        self.coordinatesList = [CLLocation]()
        self.locationRequestId = appDelegate!.startRetrievingContinuousLocation(locationManager: locationManager, block: { (location) in
            print(location)
            self.coordinatesList.append(location)
        })
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.addTarget(self, action: #selector(getCurrentLocation), for:
                .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    self.latitude = location!.coordinate.latitude
                    self.longitude = location!.coordinate.longitude
                    if #available(iOS 10.0, *) {
                        self.tableView.refreshControl?.beginRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.searchDrive(distance: self.distance!, filter: self.driveType!, withCompletionHandler: { (b) in
                            if #available(iOS 10.0, *) {
                                self.tableView.refreshControl?.endRefreshing()
                            } else {
                                // Fallback on earlier versions
                            }
                            self.tableView.reloadData()
                    })
                }
                break
            case .error:
                UIUtil.showToast(message: "Unable to get current location")
                UIUtil.hideProcessing()
                break
            default:
                UIUtil.hideProcessing()
                break
            }
        }
    }
    
    // MARK: IBActions
    func searchDrive(distance: String, filter: String, withCompletionHandler:@escaping (Bool)->())  {
        let params = [
            URLConstant.Param.TAG: "searchDrive",
            "distance": distance,
            "filter": filter,
            "_lat": String(format: "%lf", self.latitude),
            "_lng": String(format: "%lf", self.longitude)
            ] as [String : String]
        WebserviceUtil.callGet(httpRequest: URLConstant.API.SEARCH_DRIVE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.appDelegate?.stopContinuousLocation(locationManager: self.locationManager, requestId: self.locationRequestId)
                    self.searchresultArray = (json["result"] as? NSArray)?.mutableCopy() as! NSMutableArray
                    withCompletionHandler(true)

                }else {
                    UIUtil.showToast(message: json.object(forKey: "result") as! String)
                    withCompletionHandler( false)

                }
                print(json)
            }
        }, failure: { (error) in

            UIUtil.hideProcessing()
            print(error.localizedDescription)
            withCompletionHandler(false)
        })
        
    }
    func commentsClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        self.myDrive = searchresultArray.object(at: (indexPath?.row)!) as? NSDictionary
        app.driveid = Int((self.myDrive?.object(forKey: "driveid") as! NSString).intValue)
        performSegue(withIdentifier: "SEARCH_COMMENT", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "SEARCH_COMMENT" {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.isdrive = true
                    dvc.dict = self.myDrive!
                    dvc.driveid = app.driveid
                }
            }else if identifier == "SEARCH_VIDEO" {
                if let dvc = segue.destination as? VideoViewController {
                    dvc.link = self.videoLink
                }
            }else if identifier == "SEARCH_DRIVE" {
                if let dvc = segue.destination as? DriveMapStartViewController {
                    dvc.driveid = app.driveid
                    dvc.myDrive = (searchresultArray.object(at: selectedIndex) as? NSDictionary)!
                }
            }else if identifier == "SearchToOtherUserProfile" {
                if let dvc = segue.destination as? OtherUserProfileViewController {
                    let dict = searchresultArray.object(at: selectedIndex) as! NSDictionary
                    dvc.otheruserid = dict.object(forKey: "creator_id") as! String
                }

            }

        }
    }

    func shareClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
        let snimage = self.tableView.snapshotRows(at: [indexPath!])!

        if let myWebsite = NSURL(string: dict["videolink"] as! String) {
            let textToShare = "This is my awesome drive!  Check out this youtube url about it!"
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
    
    func likesClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
        let userid = model.userid()
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
            "creator_id": userid,
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

                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }else{
                        let cell = self.tableView.cellForRow(at: indexPath!) as! FeedTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count - 1
                        cell.lblLikeCount.text = "\(count)"
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
    func driveItClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: "SEARCH_DRIVE", sender: self)
    }

    func playClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        let dict = searchresultArray.object(at: (indexPath?.row)!) as! NSDictionary
        videoLink = (dict.object(forKey: "videolink") as! String?)!
        if videoLink != ""{
            performSegue(withIdentifier: "SEARCH_VIDEO", sender: self)
        }
    }

    func otherUserProfile(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        selectedIndex = (indexPath?.row)!
        let dict = searchresultArray.object(at: selectedIndex) as! NSDictionary
        if (dict.object(forKey: "creator_id") as! String) == model.userid() {
            self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![4]
            self.tabBarController?.selectedIndex = 4
        }else{
            performSegue(withIdentifier: "SearchToOtherUserProfile", sender: self)
        }
    }

}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if searchresultArray.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchresultArray.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell
        let dict = searchresultArray.object(at: indexPath.row) as! NSDictionary

        // Setting Up Comments Click
        cell.btnComment.addTarget(self, action: #selector(SearchResultsViewController.commentsClick(sender:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(SearchResultsViewController.likesClick(sender:)), for: .touchUpInside)
        cell.btnDrive.addTarget(self, action: #selector(SearchResultsViewController.driveItClick(sender:)), for: .touchUpInside)
        cell.btnShare.addTarget(self, action: #selector(SearchResultsViewController.shareClick(sender:)), for: .touchUpInside)
        cell.btnOtherUserProfile.addTarget(self, action: #selector(SearchResultsViewController.otherUserProfile(_ :)), for: .touchUpInside)
        // Settings Up Play Click
        cell.btnPlayVideo.addTarget(self, action: #selector(SearchResultsViewController.playClick(sender:)), for: .touchUpInside)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.myDrive = searchresultArray.object(at: indexPath.row) as? NSDictionary
//        performSegue(withIdentifier: DRIVE_DETAIL_IDENTIFIER, sender: self)

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
