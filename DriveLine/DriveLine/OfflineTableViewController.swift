//
//  OfflineTableViewController.swift
//  DriveLine
//
//  Created by mac on 2017-10-13.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import UILoadControl
import INTULocationManager
import MobileCoreServices

class OfflineTableViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var model = UserModel.shared
    var videoLink:String = ""
    let app = UIApplication.shared.delegate as! AppDelegate
    var selectedIndex = 0
    var myDrives = NSMutableArray.init()
    let locationManager = INTULocationManager.sharedInstance()
    var locationRequestId = INTULocationRequestID()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "OfflineTableViewCell", bundle: nil), forCellReuseIdentifier: "offlineCell")
        self.navigationController?.navigationBar.tintColor = .black
        initViews()
        // Do any additional setup after loading the view.
    }

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
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl?.beginRefreshing()
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
        getMyDrives()

    }

    //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }

    //load more tableView data
    func loadMore(sender: AnyObject?) {
        self.getMyDrives()
    }
    func loadRecent(sender: AnyObject?) {
        self.getMyDrives()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //        initViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    SharedAppDelegate.lat = location!.coordinate.latitude
                    SharedAppDelegate.lng = location!.coordinate.longitude
                    self.getMyDrives()
                }
                break
            case .error:
                UIUtil.showToast(message: "Unable to get current location")
                self.getMyDrives()

                break
            default:
                break
            }
        }
    }

    func getMyDrives() {
        myDrives = ModelManager.getInstance().getAllDriveData().mutableCopy() as! NSMutableArray
        if myDrives.count > 0 {
            if !SharedAppDelegate.uploadTimer.isValid {
                SharedAppDelegate.setTimer()
            }
        }
        self.tableView.loadControl?.endLoading() //Update UILoadControl frame to the new UIScrollView bottom.
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl?.endRefreshing()
        } else {
            // Fallback on earlier versions
        }
        self.tableView.reloadData()
    }

}
extension OfflineTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
            if myDrives.count > 0
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myDrives.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offlineCell", for: indexPath) as! OfflineTableViewCell

        cell.selectionStyle = .none
        let mydrive = myDrives.object(at: indexPath.row) as! DataModel
        if (mydrive.thumburl) != "" {
            cell.imvMap.setImageWith(NSURL(string: mydrive.thumburl)! as URL, placeholderImage: UIImage(named: "drive"))
            cell.btnAddVideo.isHidden = true
        }else{
            let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = mydrive.driveimage.components(separatedBy: "/").last
            let imagefilepath = filepath.appendingPathComponent(filename!)
            cell.imvMap.image = UIImage(contentsOfFile: imagefilepath.path)
            cell.btnAddVideo.isHidden = true
        }
        cell.lblDriveTitle.text = mydrive.drivename
        cell.lblStyle.text = "Style: "+(mydrive.screentype)
        cell.lblTime.text = "Time: "+getElapsTime(mydrive.starttime, mydrive.endtime)
        let firstPoint = CLLocation(latitude: SharedAppDelegate.lat, longitude: SharedAppDelegate.lng)
        let secondPoint = CLLocation(latitude: Double(mydrive.startlat)!, longitude: Double(mydrive.startlng)!)
        let distancehere = firstPoint.distance(from: secondPoint) / 1609
        cell.lblToStart.text = "To Start: "+String(Int(distancehere))+" miles"
        let length = Float(mydrive.waylength)! / 1609.0
        cell.lblLength.text = "Length: "+String(format: "%.3f miles", length)
        cell.btnDelete.addTarget(self, action: #selector(OfflineTableViewController.deleteClick(sender:)), for: .touchUpInside)
        return cell
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

    func deleteClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let dict = myDrives.object(at: (indexPath?.row)!) as! DataModel

        let resultid = ModelManager.getInstance().deleteDriveData(dataInfo: dict)
        if resultid {
            getMyDrives()
        }else{
            Util.invokeAlertMethod(strTitle: "Error", strBody: "Cannot delete the data", delegate: nil)
        }
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.65
    }
}

