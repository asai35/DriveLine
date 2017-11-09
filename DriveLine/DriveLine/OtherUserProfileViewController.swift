//
//  OtherUserProfileViewController.swift
//  DriveLine
//
//  Created by mac on 10/2/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import UILoadControl
import AVFoundation
import Photos
import MobileCoreServices
import MessageUI
class OtherUserProfileViewController: UIViewController, UIScrollViewDelegate {
    var backgroundTask = UIBackgroundTaskInvalid

    let DRIVE_DETAIL_IDENTIFIER = "DRIVE_DETAIL_IDENTIFIER"
    let EDIT_CAR = "EDIT_CAR"
    let PROFILE_DRIVE_DETAIL = "PROFILE_DRIVE_DETAIL"

    // MARK: IBOutlets
    @IBOutlet weak var myCarViewButton: UIView!
    @IBOutlet weak var myDrivesViewButton: UIView!
    @IBOutlet weak var btnFollow: UIButton!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!

    @IBOutlet weak var myCarsTableView: UITableView!
    @IBOutlet weak var myDrivesTableView: UITableView!

    @IBOutlet weak var myCarsCount: UILabel!
    @IBOutlet weak var myCarsTitle: UILabel!

    @IBOutlet weak var myDrivesCount: UILabel!
    @IBOutlet weak var myDrivesTitle: UILabel!

    @IBOutlet weak var segmentControl: UISegmentedControl!
    var controller = UIImagePickerController()
    let app = UIApplication.shared.delegate as! AppDelegate
    var userImage = UIImage()
    var asset = PHAsset()
    var videoPath: URL!
    var progressBar : UIProgressView!
    var btnBarBadge : MJBadgeBarButton!
    var selectedIndex = 0

    var otheruserid = ""
    var otherUserProfile = NSMutableDictionary()// = [String: Any]()
    var selectedDrive = NSDictionary()
    var carArray = NSMutableArray()
    var driveArray = NSMutableArray()
    // MARK: Variables
    var model = UserModel.shared
    var myCar:NSDictionary = [:]
    var myDrive:NSDictionary = [:]
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myDrivesTableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "profileCell")
        self.navigationController?.navigationBar.tintColor = .black
        initViews()
    }

    var driveID:Int = 0
    var videostyle: String = ""
    var videotitle: String = ""
    // MARK: Helper Methods

    func initViews() {
        userImageView.layer.cornerRadius = 50 / 2
        userImageView.clipsToBounds = true

        myCarsTableView.tableFooterView = UIView()
        myDrivesTableView.tableFooterView = UIView()
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)

        myCarViewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.myCarViewClick)))
        myDrivesViewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.myDrivesViewClick)))

        myCarViewButton.backgroundColor = .black
        myDrivesViewButton.backgroundColor = .lightGray

        myCarsCount.textColor = .red
        myDrivesCount.textColor = .red
        self.segmentControl.selectedSegmentIndex = 0;
        self.segmentControl.setTitle("0 Cars", forSegmentAt: 0)
        self.segmentControl.setTitle("0 Drives", forSegmentAt: 1)

        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        myCarsTableView.loadControl = UILoadControl(target: self, action: #selector(loadMoreCar(sender:)))
        myCarsTableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        myDrivesTableView.loadControl = UILoadControl(target: self, action: #selector(loadMoreDrive(sender:)))
        if #available(iOS 10.0, *) {
            myCarsTableView.refreshControl = UIRefreshControl()
            myCarsTableView.refreshControl?.addTarget(self, action: #selector(loadMoreCar(sender:)), for: .valueChanged)
            myDrivesTableView.refreshControl = UIRefreshControl()
            myDrivesTableView.refreshControl?.addTarget(self, action: #selector(loadMoreDrive(sender:)), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        myDrivesTableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        myCarsTableView.isHidden = false
        myDrivesTableView.isHidden = true
        if #available(iOS 10.0, *) {
            self.myCarsTableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }
        self.segmentControl.selectedSegmentIndex = 0;

        getUserProfile()
    }

    func showProfile() {
        self.segmentControl.setTitle(String(format: "%d Cars", Int(otherUserProfile.object(forKey: "mycars") as! String)!), forSegmentAt: 0)
        self.segmentControl.setTitle(String(format: "%d Drives", Int(otherUserProfile.object(forKey: "mydrives") as! String)!), forSegmentAt: 1)
        userName.text = otherUserProfile.object(forKey: "name") as? String
        userPoints.text = "\(otherUserProfile.object(forKey: "points") as! String) points"
        if URL(string: otherUserProfile.object(forKey: "photo_url") as! String) == nil {
            userImageView.image = #imageLiteral(resourceName: "person-avatar")
        }else{
            userImageView.setImageWith(URL(string: otherUserProfile.object(forKey: "photo_url") as! String)!, placeholderImage: UIImage(named: "person-avatar"))
        }
        if (otherUserProfile.object(forKey: "follow") as! String) == "1" {
            self.btnFollow.isSelected = true
        }else{
            self.btnFollow.isSelected = false
        }
    }

    func getUserProfile() {
        let params = [
            URLConstant.Param.TAG: "userprofile",
            "user_id" : self.model.userid(),
            "other_user_id" : otheruserid
            ] as [String : String]
        print (params)
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.USER_PROFILE, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.otherUserProfile = json.mutableCopy() as! NSMutableDictionary
                    self.showProfile()

                }else {
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }

    func editUserImage() {
        let alert = UIAlertController.init(title: "User Photo", message: "", preferredStyle: .actionSheet)
        let photo = UIAlertAction.init(title: "Photo Library", style: .default) { (action) in
            self.selectImageFromGallery()
        }
        let camera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            self.captureImageCamera()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(camera)
        alert.addAction(photo)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    func selectImageFromGallery() {
        controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        controller.allowsEditing = true
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    func selectedImage(image: UIImage) {
        userImageView.image = image
        let params = [URLConstant.Param.TAG: "profile",
                      URLConstant.Param.USERID: model.userid()]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.UPLOAD_USER_PHOTO, params: params , image: self.userImage, imageParam: "image", success: { (response) in

            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    let photourl = json["photourl"] as! String
                    self.model.photoUrl(photourl)
                    self.userImageView.setImageWith(URL(string: photourl)!, placeholderImage: UIImage(named: "person-avatar"))
                }else {
                    UIUtil.showToast(message: json["response"] as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }

    func captureImageCamera() {
        controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.camera
        controller.allowsEditing = true
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }

    //load more tableView data
    func loadMoreCar(sender: AnyObject?) {
        if carArray.count == 0{
            if #available(iOS 10.0, *) {
                self.myCarsTableView.refreshControl?.beginRefreshing()
            } else {
                // Fallback on earlier versions
            }
        }
        callMyCarApi()
    }
    func loadMoreDrive(sender: AnyObject?) {
        if #available(iOS 10.0, *) {
            self.myDrivesTableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }

        callMyDriveApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callMyCarApi()
    }

    func myCarViewClick() {

        myCarsTableView.isHidden = false
        myDrivesTableView.isHidden = true
        callMyCarApi()
    }

    func myDrivesViewClick() {
        myCarsTableView.isHidden = true
        myDrivesTableView.isHidden = false
        callMyDriveApi()
    }


    // MARK: IBActions
    @IBAction func addClick(_ sender: Any) {
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myCarViewClick()
        }else if sender.selectedSegmentIndex == 1 {
            myDrivesViewClick()
        }
    }
    @IBAction func ActionReport(_ sender: UIButton) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    func callMyCarApi() {
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYRIDES, params: ["tag": "showmyride", "creator_id": otheruserid], success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.carArray = (json["myride"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.otherUserProfile.setValue(String(self.carArray.count), forKey: "mycars")
                    self.segmentControl.setTitle(String(format: "%d Cars", Int(self.otherUserProfile.object(forKey: "mycars") as! String)!), forSegmentAt: 0)
                    self.myCarsTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myCarsTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myCarsTableView.reloadData()
                }else {
                    self.myCarsTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myCarsTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                }
                print(json)
            }

        }, failure: { (error) in
            UIUtil.hideProcessing()
        })
    }

    func callMyDriveApi() {
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYDRIVE, params: ["tag": "showmydrive", "creator_id": otheruserid, "user_id": model.userid()], success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.driveArray = (json["mydrive"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.otherUserProfile.setValue(String(self.driveArray.count), forKey: "mydrives")
                    self.segmentControl.setTitle(String(format: "%d Drives", Int(self.otherUserProfile.object(forKey: "mydrives") as! String)!), forSegmentAt: 1)
                    self.myDrivesTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myDrivesTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myDrivesTableView.reloadData()
                }else {
                    self.driveArray = NSMutableArray.init()
                    self.myDrivesTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myDrivesTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myDrivesTableView.reloadData()
                }
                print(json)
            }

        }, failure: { (error) in
            UIUtil.hideProcessing()
        })
    }
    func commentsClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myDrivesTableView)
        let indexPath = self.myDrivesTableView.indexPathForRow(at: buttonPosition)
        myDrive = driveArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int((myDrive.object(forKey: "driveid") as! NSString).intValue)
        performSegue(withIdentifier: "USERPROFILE_COMMENT", sender: self)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "USERPROFILE_COMMENT" {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.dict = myDrive
                    dvc.driveid = app.driveid
                    dvc.isdrive = true
                }
            }else if identifier == "USERPROFILE_VIDEO"{
                if let dvc = segue.destination as? VideoViewController {
                    dvc.link = (driveArray.object(at: selectedIndex) as? NSDictionary)?.object(forKey: "videolink") as! String

                }
            }else if identifier == "USERPROFILE_DRIVE"{
                if let dvc = segue.destination as? DriveMapStartViewController {
                    dvc.driveid = app.driveid
                    dvc.myDrive = (driveArray.object(at: selectedIndex) as? NSDictionary)!
                }
            }
        }
    }

    func driveItClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myDrivesTableView)
        let indexPath = self.myDrivesTableView.indexPathForRow(at: buttonPosition)
        let dict = driveArray.object(at: (indexPath?.row)!) as! NSDictionary
        app.driveid = Int(dict.object(forKey: "driveid") as! String)!
        selectedIndex = (indexPath?.row)!
        performSegue(withIdentifier: "USERPROFILE_DRIVE", sender: self)
    }

    func shareClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.myDrivesTableView)
        let indexPath = self.myDrivesTableView.indexPathForRow(at: buttonPosition)
        let dict = driveArray.object(at: (indexPath?.row)!) as! NSDictionary
        let snimage = self.myDrivesTableView.snapshotRows(at: [indexPath!])!

        if let myWebsite = NSURL(string: dict["videolink"] as! String) {
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

    }

    func callShareApi() {

        let params = [
            URLConstant.Param.TAG: "share",
            "creator_id" : self.model.userid()
            ] as [String : String]
        print (params)
//        UIUtil.showProcessing(message: "Please wait")
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
        let buttonPosition = sender.convert(CGPoint(), to: self.myDrivesTableView)
        let indexPath = myDrivesTableView.indexPathForRow(at: buttonPosition)
        let dict = driveArray.object(at: (indexPath?.row)!) as! NSDictionary
        self.myDrivesTableView.isUserInteractionEnabled = false
        let cell = self.myDrivesTableView.cellForRow(at: indexPath!) as! ProfileTableViewCell
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
                        let cell = self.myDrivesTableView.cellForRow(at: indexPath!) as! ProfileTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count + 1
                        cell.lblLikeCount.text = "\(count)"
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }else{
                        let cell = self.myDrivesTableView.cellForRow(at: indexPath!) as! ProfileTableViewCell
                        var count = Int(cell.lblLikeCount.text!)!
                        count = count - 1
                        cell.lblLikeCount.text = "\(count)"
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                    }
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
                self.myDrivesTableView.isUserInteractionEnabled = true
            }
        }) { (error) in
            self.myDrivesTableView.isUserInteractionEnabled = true
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    @IBAction func ActionFollow(_ sender: UIButton) {
        self.btnFollow.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1.0,
                       delay: 0.5,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: .curveLinear,
                       animations: {
                        self.btnFollow.transform = CGAffineTransform.identity
        },
                       completion: nil
        )

        let params = [
            URLConstant.Param.TAG: "follow",
            "user_id": model.userid(),
            "follow_user_id": otheruserid
            ] as [String : String]
        WebserviceUtil.callPost(httpRequest: URLConstant.API.FOLLOW, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    if json.object(forKey: "follow") as! String == "follow"{
                        self.btnFollow.isSelected = true

                    }else{
                        self.btnFollow.isSelected = false
                    }
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
                self.myDrivesTableView.isUserInteractionEnabled = true
            }
        }) { (error) in
            self.myDrivesTableView.isUserInteractionEnabled = true
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }
}

extension OtherUserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if tableView == myCarsTableView {
            if carArray.count > 0
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                //                noDataLabel.text          = "No data available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }else{
            if driveArray.count > 0
            {
                tableView.separatorStyle = .singleLine
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                //                noDataLabel.text          = "No data available"
                noDataLabel.textColor     = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.myCarsTableView == tableView {
            return carArray.count
        }
        return driveArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myCarsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyCarCell
            cell.selectionStyle = .none
            let mycar = carArray.object(at: indexPath.row) as! NSDictionary
            if URL(string: mycar["car"] as! String) == nil {
                cell.carImageView.image = #imageLiteral(resourceName: "car_placeholder")
            }else{
                cell.carImageView.setImageWith(URL(string: mycar["car"] as! String)!, placeholderImage: UIImage(named: ""))
            }
            cell.lblYear.text = mycar["year"] as? String
            cell.lblMake.text = mycar["make"] as? String
            cell.lblModel.text = mycar["model"] as? String
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell

            cell.selectionStyle = .none
            let mydrive = driveArray.object(at: indexPath.row) as! NSDictionary
            if (mydrive.object(forKey: "thumb_image") as! String) == "" {
                cell.imvMap.setImageWith(NSURL(string: mydrive.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            }else{
                cell.imvMap.setImageWith(NSURL(string: mydrive.object(forKey: "img") as! String)! as URL, placeholderImage: UIImage(named: "drive"))
            }
            cell.btnAddVideo.isHidden = true
            cell.lblDriveTitle.text = mydrive["drivename"] as? String
            cell.lblStyle.text = "Style: "+(mydrive["screentype"] as? String)!
            cell.lblLikeCount.text = "\(mydrive["like_count"]!)"
            cell.lblCommentCount.text = "\(mydrive["comment_count"]!)"
            cell.btnComment.addTarget(self, action: #selector(ProfileViewController.commentsClick(sender:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(ProfileViewController.likesClick(sender:)), for: .touchUpInside)
            cell.btnShare.addTarget(self, action: #selector(ProfileViewController.shareClick(sender:)), for: .touchUpInside)
            cell.btnDriveit.addTarget(self, action: #selector(ProfileViewController.driveItClick(sender:)), for: .touchUpInside)
            cell.lblTime.text = "Time: "+getElapsTime(mydrive["starttime"] as! String, mydrive["endtime"] as! String)
            let firstPoint = CLLocation(latitude: SharedAppDelegate.lat, longitude: SharedAppDelegate.lng)
            let secondPoint = CLLocation(latitude: Double(mydrive["startlat"] as! String)!, longitude: Double(mydrive["startlng"] as! String)!)
            let distancehere = firstPoint.distance(from: secondPoint) / 1609
            cell.lblToStart.text = "To Start: "+String(Int(distancehere))+" miles"
            let length = Float((mydrive["waylength"] as? String)!)! / 1609.0
            cell.lblLength.text = "Length: "+String(format: "%.3f miles", length)
            cell.btnDelete.isHidden = true
//            cell.btnDelete.addTarget(self, action: #selector(ProfileViewController.deleteClick(sender:)), for: .touchUpInside)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myCarsTableView {
//            myCar = carArray.object(at: indexPath.row) as! NSDictionary
//            performSegue(withIdentifier: EDIT_CAR, sender: self)
        }else{
            //            myDrive = driveArray.object(at: indexPath.row) as! NSDictionary
            //            performSegue(withIdentifier: PROFILE_DRIVE_DETAIL, sender: self)

        }
    }

    func callYoutubApi(_ driveid: Int,  _ video: String, _ style: String) {
        if driveID == 0 {
            return
        }
        let params = [
            "video_title" : video,
            "drive_id" : driveid,
            "video_description" : style
            ] as [String : Any]
        print (params)
        self.myDrivesTableView.isScrollEnabled = false
        self.myDrivesTableView.isUserInteractionEnabled = false
        self.progressBar.isHidden = false
        self.progressBar.progress = 0
        let fileSize = (try! FileManager.default.attributesOfItem(atPath: self.videoPath.path)[FileAttributeKey.size] as! NSNumber).uint64Value
        print("file size: \(fileSize)")
        if fileSize > 150000000 {
            DispatchQueue.main.async {

                UIUtil.showMessage(title: "Video upload", message: "Your video is too large for uploading to the youtube.\nPlease select or record again as the small one!", controller: self, okHandler: {
                    UIUtil.hideProcessing()
                })
                return
            }
        }else{
            DispatchQueue.global(qos: .userInitiated).async {

                var videodata = Data.init()
                if self.videoPath != nil{
                    videodata = try! Data(contentsOf: self.videoPath, options: .mappedIfSafe)
                }
                DispatchQueue.main.async {
                    UIUtil.showProcessing(message: "Uploading Video")
                    WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.UPLOAD_VIDEO, params: params, video: videodata, videoParam: "video", progress: { (progress) in
                        DispatchQueue.main.async {
                            self.progressBar.progress = Float((progress?.fractionCompleted)!)
                            print(progress?.fractionCompleted ?? "")
                        }

                    },  success: { (response) in

                        UIUtil.hideProcessing()

                        self.progressBar.isHidden = true
                        if let json = response as? NSDictionary {
                            if WebserviceUtil.isStatusOk(json: json) {
                                self.driveID = 0
                                self.videotitle = ""
                                self.videostyle = ""
                                UIUtil.showMessage(title: "", message: "Upload video successfully", controller: self, okHandler: nil)
                                self.callMyDriveApi()

                            }else {
                                UIUtil.showToast(message: "Failed, please try again")
                            }
                            print(json)

                        }
                        self.myDrivesTableView.isScrollEnabled = true
                        self.myDrivesTableView.isUserInteractionEnabled = true
                    }) { (error) in
                        UIUtil.hideProcessing()

                        self.progressBar.isHidden = true
                        UIUtil.showMessage(title: "", message: error.localizedDescription, controller: self, okHandler: nil)
                        print(error.localizedDescription)
                        self.myDrivesTableView.isScrollEnabled = true
                        self.myDrivesTableView.isUserInteractionEnabled = true
                    }
                }
            }
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
        if tableView == myDrivesTableView {
            return self.view.frame.size.height * 0.75
        }
        else{
            return self.view.frame.size.height * 0.25
        }

    }


}
extension OtherUserProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {


        // 1
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType] as AnyObject
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImage = pickedImage
            selectedImage(image: pickedImage)
        }else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage = pickedImage
            selectedImage(image: pickedImage)
        }
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? URL
                    if let url = urlOfVideo {

                        let fileSize = (try! FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as! NSNumber).uint64Value
                        print("file size: \(fileSize)")
                        self.videoPath = url
                        self.callYoutubApi(driveID, videotitle, videostyle)

                    }
                }
            }
        }

        // 3
        picker.dismiss(animated: true, completion: nil)

        //        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }



}

extension OtherUserProfileViewController: MFMailComposeViewControllerDelegate{
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["support@driveline.club"])
        mailComposerVC.setSubject("Report")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

