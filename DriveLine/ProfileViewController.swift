//
//  ProfileViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import UILoadControl
import AVFoundation
import Photos
import MobileCoreServices

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    var backgroundTask = UIBackgroundTaskInvalid

    let DRIVE_DETAIL_IDENTIFIER = "DRIVE_DETAIL_IDENTIFIER"
    let EDIT_CAR = "EDIT_CAR"
    let PROFILE_DRIVE_DETAIL = "PROFILE_DRIVE_DETAIL"
    
    // MARK: IBOutlets
    @IBOutlet weak var myCarViewButton: UIView!
    @IBOutlet weak var myDrivesViewButton: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    
    @IBOutlet weak var myCarsTableView: UITableView!
    @IBOutlet weak var myDrivesTableView: UITableView!
    
    @IBOutlet weak var myCarsCount: UILabel!
    @IBOutlet weak var myCarsTitle: UILabel!
    
    @IBOutlet weak var myDrivesCount: UILabel!
    @IBOutlet weak var myDrivesTitle: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var controller = UIImagePickerController()

    var asset = PHAsset()
    var videoPath: URL!

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
        initViews()
    }

    var driveID:Int = 0
    var videostyle: String = ""
    var videotitle: String = ""
    // MARK: Helper Methods
    func initViews() {
        userImageView.layer.cornerRadius = 50 / 2
        myCarsTableView.tableFooterView = UIView()
        myDrivesTableView.tableFooterView = UIView()
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        
        myCarViewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.myCarViewClick)))
        myDrivesViewButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.myDrivesViewClick)))
        
        myCarViewButton.backgroundColor = .black
        myDrivesViewButton.backgroundColor = .lightGray
        
        myCarsCount.textColor = .red
        myDrivesCount.textColor = .red
        
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        myCarsTableView.loadControl = UILoadControl(target: self, action: #selector(loadMoreCar(sender:)))
        myCarsTableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        myDrivesTableView.loadControl = UILoadControl(target: self, action: #selector(loadMoreDrive(sender:)))
        if #available(iOS 10.0, *) {
            myCarsTableView.refreshControl = UIRefreshControl()
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            myCarsTableView.refreshControl?.addTarget(self, action: #selector(loadMoreCar(sender:)), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            myDrivesTableView.refreshControl = UIRefreshControl()
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            myDrivesTableView.refreshControl?.addTarget(self, action: #selector(loadMoreDrive(sender:)), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
        myDrivesTableView.loadControl?.heightLimit = 100.0 //The default is 80.0
        myCarsTableView.isHidden = false
        myDrivesTableView.isHidden = true
        self.segmentControl.selectedSegmentIndex = 0;
        self.segmentControl.setTitle(model.mycars()+" Cars", forSegmentAt: 0)
        self.segmentControl.setTitle(model.mydrives()+" Drives", forSegmentAt: 1)
        if #available(iOS 10.0, *) {
            self.myCarsTableView.refreshControl?.beginRefreshing()
        } else {
            // Fallback on earlier versions
        }
        self.navigationItem.rightBarButtonItem = self.addButton
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
        userName.text = model.username()
        userPoints.text = "\(model.userpoint()) points"
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
            self.addButton.isEnabled = true
            myCarViewClick()
        }else if sender.selectedSegmentIndex == 1 {
            self.addButton.isEnabled = false
            myDrivesViewClick()
        }
    }
    
    func callMyCarApi() {
//                UIUtil.showProcessing(message: "Pelase wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYRIDES, params: ["tag": "showmyride", "creator_id": model.userid() as String], success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.carArray = (json["myride"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.segmentControl.setTitle("\(self.carArray.count) Cars", forSegmentAt: 0)
                    self.model.mycars("\(self.carArray.count)")
                    self.myCarsTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myCarsTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                    self.myCarsTableView.reloadData()
                }else {
                    UIUtil.showToast(message: json["response"] as! String)
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
//                UIUtil.showProcessing(message: "Pelase wait")
        let uid = model.userid()
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_MYDRIVE, params: ["tag": "showmydrive", "creator_id": uid], success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.driveArray = (json["mydrive"] as! NSArray).mutableCopy() as! NSMutableArray
                    self.segmentControl.setTitle("\(self.driveArray.count) Drives", forSegmentAt: 1)
                    
                    self.model.mydrives("\(self.driveArray.count)")
                    self.myDrivesTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myDrivesTableView.refreshControl?.endRefreshing()
                    } else {
                        // Fallback on earlier versions
                    }
                   self.myDrivesTableView.reloadData()
                }else {
                    UIUtil.showToast(message: json["response"] as! String)
                    self.myDrivesTableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
                    if #available(iOS 10.0, *) {
                        self.myDrivesTableView.refreshControl?.endRefreshing()
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
    func commentsClick(sender: UIButton) {
        let app = UIApplication.shared.delegate as! AppDelegate
        var index = sender.tag - 2000
        if index >= 1000{
            index = index - 1000
        }
        myDrive = driveArray.object(at: index) as! NSDictionary
        app.driveid = Int((myDrive.object(forKey: "driveid") as! NSString).intValue)
        performSegue(withIdentifier: "COMMENTS_DRIVE", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "COMMENTS_DRIVE" {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.dict = myDrive
                    dvc.driveid = Int((myDrive.object(forKey: "driveid") as! NSString).intValue)
                    dvc.isdrive = true
                }
            }else if identifier == EDIT_CAR{
                if let dvc = segue.destination as? EditCarTableViewController {
                    dvc.myCar = self.myCar
                }
            }else if identifier == PROFILE_DRIVE_DETAIL{
                if let dvc = segue.destination as? DriveDetailViewController {
                    dvc.myDrive = self.myDrive
                }
            }
        }
    }

    func likesClick(sender: UIButton) {
        var index = sender.tag - 4000
        if index >= 1000{
            index = index - 1000
        }
        let dict = driveArray.object(at: index) as! NSDictionary
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
                    }else{
                        let button = sender.superview?.viewWithTag(index + 4000) as! UIButton
                        var count = Int(button.currentTitle!.replacingOccurrences(of: " likes", with: ""))! as Int
                        count = count - 1
                        button.setTitle("\(count) likes", for: UIControlState.normal)
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

    func addVideoClick(sender: UIButton) {
        var index = sender.tag - 6000
        if index >= 1000{
            index = index - 1000
        }
        let dict = driveArray.object(at: index) as! NSDictionary
        driveID = Int((dict.object(forKey: "driveid") as! NSString).intValue)
        videotitle = dict.object(forKey: "drivename") as! String
        videostyle = dict.object(forKey: "screentype") as! String

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

            // 2 Present UIImagePickerController to take video
            controller.sourceType = .photoLibrary
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            print("Camera is not available")
        }
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
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
                noDataLabel.text          = "No data available"
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
                noDataLabel.text          = "No data available"
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
            cell.carImageView.setImageWith(URL(string: mycar["car"] as! String)!, placeholderImage: UIImage(named: ""))
            cell.lblYear.text = mycar["year"] as? String
            cell.lblMake.text = mycar["make"] as? String
            cell.lblModel.text = mycar["model"] as? String
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyDriveCell
            cell.selectionStyle = .none
            let mydrive = driveArray.object(at: indexPath.row) as! [String: Any]
            cell.driveImageView.setImageWith(URL(string: mydrive["img"] as! String)!, placeholderImage: UIImage(named: ""))
            cell.lblDriveName.text = mydrive["drivename"] as? String
            cell.lblDriveType.text = mydrive["screentype"] as? String
            cell.btnLike.setTitle((mydrive["like_count"] as? String)!+" likes", for: .normal)
            cell.btnComment.setTitle((mydrive["comment_count"] as? String)!+" comments", for: .normal)
            cell.btnComment.tag = indexPath.row + 2000
            cell.btnLike.tag = indexPath.row + 4000
            cell.btnAddVideo.tag = indexPath.row + 6000
            if (mydrive["videolink"] as? String) == "" {
                cell.btnAddVideo.isHidden = false
            }else{
                cell.btnAddVideo.isHidden = true
            }
            cell.btnComment.addTarget(self, action: #selector(ProfileViewController.commentsClick(sender:)), for: .touchUpInside)
            cell.btnAddVideo.addTarget(self, action: #selector(ProfileViewController.addVideoClick(sender:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(ProfileViewController.likesClick(sender:)), for: .touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myCarsTableView {
            myCar = carArray.object(at: indexPath.row) as! NSDictionary
            performSegue(withIdentifier: EDIT_CAR, sender: self)
        }else{
            myDrive = driveArray.object(at: indexPath.row) as! NSDictionary
            performSegue(withIdentifier: PROFILE_DRIVE_DETAIL, sender: self)
            
        }
    }

    func callYoutubApi(_ driveid: Int,  _ video: String, _ style: String) {
        if driveID == 0 {
            return
        }
        let app = UIApplication.shared

        let endBackgroundTask = {
            if self.backgroundTask != UIBackgroundTaskInvalid {
                app.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskInvalid
                UIUtil.hideProcessing()
            }
        }
        backgroundTask = app.beginBackgroundTask(withName: "com.domain.app.imageupload") {
            // if you need to do any addition cleanup because request didn't finish in time, do that here

            // then end the background task (so iOS doesn't summarily terminate your app
            endBackgroundTask()
        }
        let params = [
            "video_title" : video,
            "drive_id" : driveid,
            "video_description" : style
            ] as [String : Any]
        print (params)

        UIUtil.showProcessing(message: "Uploading video")
        DispatchQueue.global(qos: .userInitiated).async {

            var videodata = Data.init()
            if self.videoPath != nil{
                videodata = try! Data(contentsOf: self.videoPath, options: .mappedIfSafe)
            }
            DispatchQueue.main.async {
                WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.UPLOAD_VIDEO, params: params, video: videodata, videoParam: "video",  success: { (response) in
                    endBackgroundTask()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            UIUtil.showToast(message: "Success to upload video")
                            self.driveID = 0
                            self.videotitle = ""
                            self.videostyle = ""
                        }else {
                            UIUtil.showToast(message: "Failed, please try again")
                        }
                        print(json)
                    }

                }) { (error) in
                    UIUtil.hideProcessing()
                    endBackgroundTask()
                    print(error.localizedDescription)
                }
            }
        }

    }
    

   
}
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // 1
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType] as AnyObject

        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? URL
                    if let url = urlOfVideo {
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
