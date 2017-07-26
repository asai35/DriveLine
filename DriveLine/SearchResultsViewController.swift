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
   
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let app = UIApplication.shared.delegate as! AppDelegate
        var index = sender.tag - 2000
        if index >= 1000{
            index = index - 1000
        }
        self.myDrive = searchresultArray.object(at: index) as? NSDictionary
        app.driveid = Int((self.myDrive?.object(forKey: "driveid") as! NSString).intValue)
        performSegue(withIdentifier: "COMMENTS_DRIVE", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "COMMENTS_DRIVE" {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.isdrive = true
                    dvc.dict = self.myDrive!
                }
            }
            else if identifier == DRIVE_DETAIL_IDENTIFIER {
                if let dvc = segue.destination as? DriveDetailViewController {
                    dvc.myDrive = self.myDrive!
                }
            }
        }
    }
    
    func likesClick(sender: UIButton) {
        var index = sender.tag - 4000
        if index >= 1000{
            index = index - 1000
        }
        let dict = searchresultArray.object(at: index) as! NSDictionary
        let userid = model.userid()
        let params = [
            URLConstant.Param.TAG: "like",
            "creator_id": userid,
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
            noDataLabel.text          = "No data available"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyDriveCell
        
        cell.selectionStyle = .none
        let mydrive = searchresultArray.object(at: indexPath.row) as! NSDictionary
        cell.driveImageView.setImageWith(URL(string: mydrive["img"] as! String)!, placeholderImage: UIImage(named: ""))
        cell.lblDriveName.text = mydrive["drivename"] as? String
        cell.lblDriveType.text = mydrive["screentype"] as? String
        cell.btnLike.setTitle((mydrive["like_count"] as? String)!+" likes", for: .normal)
        cell.btnComment.setTitle((mydrive["comment_count"] as? String)!+" comments", for: .normal)
        cell.btnComment.tag = indexPath.row + 2000
        cell.btnLike.tag = indexPath.row + 4000
        cell.btnComment.addTarget(self, action: #selector(SearchResultsViewController.commentsClick(sender:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(SearchResultsViewController.likesClick(sender:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myDrive = searchresultArray.object(at: indexPath.row) as? NSDictionary
        performSegue(withIdentifier: DRIVE_DETAIL_IDENTIFIER, sender: self)

    }
}
