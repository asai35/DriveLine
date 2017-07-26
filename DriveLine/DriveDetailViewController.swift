//
//  DriveDetailViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/20/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import MapKit
import INTULocationManager
import MobileCoreServices
import AVKit
import AVFoundation

class DriveDetailViewController: UIViewController {
    
    let DRIVE_START_IDENTIFIER = "DRIVE_START_IDENTIFIER"
    let DRIVE_WATCH = "WATCH_DRIVE"
    let DRIVE_DISCUSSION = "DRIVE_DISCUSSION"

    // MARK: IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    
    @IBOutlet weak var driveTitle: UILabel!
    @IBOutlet weak var driveDistance: UILabel!
    @IBOutlet var mapImage: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var driveStyle: UILabel!
    @IBOutlet weak var driveTime: UILabel!
    @IBOutlet weak var driveLength: UILabel!
    
    let locationManager = INTULocationManager.sharedInstance()
    var imagePicker = UIImagePickerController()
    var locationRequestId = INTULocationRequestID()
    var coordinatesList = [CLLocation]()
    var myDrive: NSDictionary = [:]
    var model = UserModel.shared

    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        getCurrentLocation()
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        userImageView.setImageWith(URL(string: "creatorphoto")!)
        userName.text = myDrive["creatorname"] as? String
        userPoints.text = "\(myDrive["creatorpoints"]!) points"
        driveTitle.text = myDrive["drivename"] as? String
//        driveDistance.text = ""
        driveStyle.text = myDrive["screentype"] as? String
        driveTime.text = getElapsTime(myDrive["starttime"] as! String, myDrive["endtime"] as! String)
        let length = Float((myDrive["waylength"] as? String)!)! / 1609.0 
        driveLength.text = String(format: "%.3fmiles", length)
        mapImage.setImageWith(URL(string: myDrive["img"] as! String)!)
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
    
    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    let latitude = location!.coordinate.latitude
                    let longitude = location!.coordinate.longitude
                    self.showLocationOnMap(lat: latitude, lng: longitude)
                }
                break
            case .error:
                UIUtil.showToast(message: "Unable to get current location")
                break
            default:
                break
            }
        }
    }
    
    func showLocationOnMap(lat: Double, lng: Double) {
        let firstPoint = CLLocation(latitude: lat, longitude: lng)
        let secondPoint = CLLocation(latitude: Double(myDrive["startlat"] as! String)!, longitude: Double(myDrive["startlng"] as! String)!)
        let distancehere = firstPoint.distance(from: secondPoint) / 1609
        driveDistance.text = String(Int(distancehere))+" miles"
//        let location = CLLocationCoordinate2DMake(lat, lng)
//        let region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.03, 0.03))
//        let adjustRegion = self.mapView.regionThatFits(region)
//        self.mapView.setRegion(adjustRegion, animated: true)
    }

    // MARK: IBActions
    @IBAction func watchTheDriveClick(_ sender: Any) {
//        if myDrive.object(forKey: "videolink") as! String != "" {
//            performSegue(withIdentifier: DRIVE_WATCH, sender: self)
//        }
    }
    
    @IBAction func takeMeToStartClick(_ sender: Any) {
//        performSegue(withIdentifier: DRIVE_START_IDENTIFIER, sender: self)
    }
    
    @IBAction func driveDiscussionClick(_ sender: Any) {
//        performSegue(withIdentifier: DRIVE_DISCUSSION, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == DRIVE_WATCH {
                if let dvc = segue.destination as? VideoViewController {
                    if myDrive.object(forKey: "videolink") as! String != "" {
                        dvc.link = myDrive.object(forKey: "videolink") as! String
                    }
                }
            }
            else if identifier == DRIVE_START_IDENTIFIER {
                if let dvc = segue.destination as? DriveMapStartViewController {
                    dvc.driveid = Int(self.myDrive.object(forKey: "driveid") as! String)!
                }
            }
            else if identifier == DRIVE_DISCUSSION {
                if let dvc = segue.destination as? CommentsViewController {
                    dvc.driveid = Int((myDrive.object(forKey: "driveid") as! NSString).intValue)
                    dvc.dict = myDrive
                }
            }
        }
    }

}
