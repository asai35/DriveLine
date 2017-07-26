//
//  SaveDriveTableViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/21/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation
import ActionSheetPicker_3_0
import MobileCoreServices
import Photos

class SaveDriveTableViewController: UITableViewController, UITextFieldDelegate {
    var backgroundTask = UIBackgroundTaskInvalid
    // MARK: IBOutlets
    @IBOutlet weak var driveNameField: UITextField!
    @IBOutlet weak var stylesButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playVideoSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var btnShare: UIButton!

    var controller = UIImagePickerController()

    var asset = PHAsset()

    // MARK: Variables
    var videoPath: URL!
    var videosavedPath: URL!
    var mapImage: UIImage!
    var startTime: Date!
    var endTime: Date!
    var coordinateList = [CLLocation]()
    var selectedStyle = Constant.Data.DRIVE_STYLES[0]
    var model = UserModel.shared
    var startlocation: String = ""
    var endlocation: String = ""
    var distance: Double = 0
    var videoYoutubeUrl: String = ""
    var videoThumbYoutubeUrl: String = ""
    var videoID: String = ""
    var driveID: Int = 0
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.videoYoutubeUrl = ""
        self.videoThumbYoutubeUrl = ""
        self.videoID = ""
    }
    
    // MARK: Helper Methods
    func initViews() {
        startTimeLabel.text = startTime.formattedTime()
        endTimeLabel.text = endTime.formattedTime()
        stylesButton.setTitle(Constant.Data.DRIVE_STYLES[0], for: .normal)
        imageView.image = self.mapImage
        self.btnShare.isEnabled = false
        getstartAddress()
        getendAddress()
    }
    
    @IBAction func addVideoButtonPressed(_ sender: UIButton) {
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

    func playVideo() {
        if let path = self.videosavedPath {
            let videoAsset = AVAsset(url: path)
            let playerItem = AVPlayerItem(asset: videoAsset)
            
            // Play Video
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
    
    @objc func videoSavedSuccessfully(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) -> Void {
        UIUtil.hideProcessing()
        if error != nil {
            UIUtil.showToast(message: "Video Save Failed")
        }else {
            if playVideoSwitch.isOn {
                self.videosavedPath = URL(string: videoPath as String)
//                callYoutubApi(video: "video")
                callCreateDrive()
            }else {
                self.videosavedPath = URL(string: videoPath as String)
//                callYoutubApi(video: "video")
                callCreateDrive()
            }
        }
        
    }
    private func thumbnailForVideoAtURL(url: URL) -> UIImage? {

        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)

        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    func getstartAddress() {
        CLGeocoder().reverseGeocodeLocation(self.coordinateList.first!, completionHandler: { placemarks, error in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                
                return
            }
            if error == nil && (placemarks?.count)! > 0 {
                
                let pm = (placemarks?.first)! as CLPlacemark
                
                self.startlocation = self.displayLocationInfo(placemark: pm)
                
            } else {
                
                print("Problem with the data received from geocoder")
                
            }
            
        })
        
    }
    func getendAddress() {
        CLGeocoder().reverseGeocodeLocation(self.coordinateList.last!, completionHandler: { placemarks, error in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                
                return
            }
            if error == nil && (placemarks?.count)! > 0 {
                
                let pm = (placemarks?.first)! as CLPlacemark
                
                self.endlocation = self.displayLocationInfo(placemark: pm)
                
            } else {
                
                print("Problem with the data received from geocoder")
                
            }
            
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) -> String {
        
        if let containsPlacemark = placemark {
            
            //stop updating location to save battery life
            
   
            let locality = ((containsPlacemark.locality != nil) ? containsPlacemark.locality! : "") as String
            
            let postalCode = ((containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode! : "") as String
            
            let administrativeArea = ((containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea! : "") as String
            
            let country = ((containsPlacemark.country != nil) ? containsPlacemark.country! : "") as String
            
            print(locality )
            print(postalCode )
            print(administrativeArea )
            print(country )
            return locality+", "+postalCode+", "+administrativeArea+", "+country
            
        }
        else{
            return ""
        }
        
        
    }

    func callYoutubApi(video: String) {
        if driveNameField.text == "" {
            UIUtil.showToast(message: "Please type drive name")
            return;
        }
        if driveID == 0 {
            UIUtil.showToast(message: "Please create your drive")
            return
        }
        let app = UIApplication.shared
        
        let endBackgroundTask = {
            if self.backgroundTask != UIBackgroundTaskInvalid {
                app.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskInvalid
            }
        }
        backgroundTask = app.beginBackgroundTask(withName: "com.domain.app.imageupload") {
            // if you need to do any addition cleanup because request didn't finish in time, do that here
            
            // then end the background task (so iOS doesn't summarily terminate your app
            endBackgroundTask()
        }
        let waypoints = NSMutableArray.init()
        for (coordinate) in self.coordinateList.enumerated() {
            let pointlat = Double(coordinate.element.coordinate.latitude)
            let pointlng = Double(coordinate.element.coordinate.longitude)
            let waypoint = ["lat": pointlat, "lng": pointlng] as NSDictionary
            waypoints.add(waypoint)
        }
        let params = [
            "video_title" : driveNameField.text ?? "",
            "drive_id" : driveID,
            "video_description" : self.stylesButton.currentTitle!
            ] as [String : Any]
        print (params)

        
        DispatchQueue.global(qos: .userInitiated).async {
            
             var videodata = Data.init()
             if self.videosavedPath != nil{
             videodata = try! Data(contentsOf: self.videoPath, options: .mappedIfSafe)
             }
            DispatchQueue.main.async {
                UIUtil.showProcessing(message: "Uploading video")
                WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.UPLOAD_VIDEO, params: params, video: videodata, videoParam: "video",  success: { (response) in
                    UIUtil.hideProcessing()
                    endBackgroundTask()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            self.videoYoutubeUrl = "https://www.\(json["video_url"] as! String)"
                            self.videoID = json["video_id"] as! String
                            UIUtil.showToast(message: "Success to upload video")
                            self.btnShare.isEnabled = true
                            if self.playVideoSwitch.isOn == true{
                                self.playVideo()
                            }
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
    
    func callCreateDrive() {
        if driveNameField.text == "" {
            UIUtil.showToast(message: "Please type drive name")
            return;
        }
        
        let waypoints = NSMutableArray.init()
        for (coordinate) in self.coordinateList.enumerated() {
            let pointlat = Double(coordinate.element.coordinate.latitude)
            let pointlng = Double(coordinate.element.coordinate.longitude)
            let waypoint = ["lat": pointlat, "lng": pointlng] as NSDictionary
            waypoints.add(waypoint)
        }
        let start_loc = self.coordinateList.first! as CLLocation
        let end_loc = self.coordinateList.last! as CLLocation
        let start_lat = String(start_loc.coordinate.latitude)
        let end_lat = String(end_loc.coordinate.latitude)
        let start_lng = String(start_loc.coordinate.longitude)
        let end_lng = String(end_loc.coordinate.longitude)
        let dateFormatter = DateFormatter()
        let uid = model.userid()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let starttime = dateFormatter.string(from:self.startTime)
        let endtime = dateFormatter.string(from:self.endTime)
        var params = [String: Any]()
        if videoID != "" {
            params = [
                URLConstant.Param.TAG: "newdrive",
                "drivename" : driveNameField.text ?? "",
                "starttime" : starttime,
                "endtime" : endtime,
                "startloc" : startlocation,
                "endloc" : endlocation,
                "driverID" : uid,
                "startlat" : start_lat,
                "startlng" : start_lng,
                "endlat" : end_lat,
                "endlng" : end_lng,
                "waypoints" : waypoints,
                "videourl" : self.videoYoutubeUrl,
                "thumburl" : self.videoThumbYoutubeUrl,
                "videoid" : self.videoID,
                "waylength" : String(distance),
                "trackID" : "",
                "screentype" : self.stylesButton.currentTitle!
                ] as [String : Any]
        }else{
            params = [
                URLConstant.Param.TAG: "newdrive",
                "drivename" : driveNameField.text ?? "",
                "starttime" : starttime,
                "endtime" : endtime,
                "startloc" : startlocation,
                "endloc" : endlocation,
                "driverID" : uid,
                "startlat" : start_lat,
                "startlng" : start_lng,
                "endlat" : end_lat,
                "endlng" : end_lng,
                "waypoints" : waypoints,
                "waylength" : String(distance),
                "trackID" : "",
                "screentype" : self.stylesButton.currentTitle!
                ] as [String : Any]
        }
        print (params)
//        DispatchQueue.global(qos: .userInitiated).async {
//            DispatchQueue.main.async {
                UIUtil.showProcessing(message: "Please wait")
                WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.CREATE_DRIVE, params: params, image: self.mapImage, imageParam: "image",  success: { (response) in
                    UIUtil.hideProcessing()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                            self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                            self.driveID = Int(json.object(forKey: "drive_id") as! String)!
                            self.btnShare.isEnabled = true
                            self.showAddVideoAlert()

                        }else {
                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                        }
                        print(json)
                    }
                    
                }) { (error) in
                    UIUtil.hideProcessing()
                    print(error.localizedDescription)
                }
//            }
//        }

        
    }

    func showAddVideoAlert() {
        let alert = UIAlertController(title: "Add Video", message: "Now, do you want to upload video of this drive?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Now", style: .default, handler: { (action) in
            self.addVideoButtonPressed(UIButton())

        }))

        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler:{(action) in
            if self.playVideoSwitch.isOn == true{
                self.playVideo()
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }

    // MARK: TextFieldDelete Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: IBActions
    @IBAction func playVideoSwitchChanged(_ sender: Any) {
        
    }
    
    @IBAction func stylesClick(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select Drive Style", rows: Constant.Data.DRIVE_STYLES, initialSelection: 0, doneBlock: { (action, index, value) in
            if let string = value as? String {
                self.stylesButton.setTitle(string, for: .normal)
                self.selectedStyle = string
            }
        }, cancel: nil, origin: self.view)
    }
    
    @IBAction func shareClick(_ sender: Any) {
        let textToShare = "This is my awaresome drive!  Check out this youtube url about it!"
        
        if let myWebsite = NSURL(string: self.videoYoutubeUrl) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
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
    
    @IBAction func saveClick(_ sender: Any) {
        // Save Video to Gallery
        self.view.endEditing(true)
        if let path = self.videoPath {
            UISaveVideoAtPathToSavedPhotosAlbum(path.path as String, self, #selector(SaveDriveTableViewController.videoSavedSuccessfully(videoPath:didFinishSavingWithError:contextInfo:)), nil)
        }else{
            callCreateDrive()
        }
    }

    @IBAction func cancelClick(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
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

    
}
extension SaveDriveTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
                                callYoutubApi(video: "video")

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

