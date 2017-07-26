//
//  DriveViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import MapKit
import INTULocationManager
import MobileCoreServices
import AVKit
import AVFoundation

class DriveViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    let SAVE_DRIVE_IDENTIFIER = "SAVE_DRIVE_IDENTIFIER"
    var snapShotImage: UIImage?
    
    @IBOutlet var btnSave: UIButton!
    @IBOutlet var btnClear: UIButton!
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var driveStartButton: UIButton!
    var txtField: UITextField?
    var videodata : Data?
    // MARK: Variables
    var isTracking = false
    var latitude = 0.0
    var longitude = 0.0
    var videoSavePath: URL!
    var isVideoCaptured = false
    var startTime = Date()
    var endTime = Date()
    var distance : Double = 0
    var isVideoRecording = false
    let locationManager = INTULocationManager.sharedInstance()
    var imagePicker = UIImagePickerController()
    var locationRequestId = INTULocationRequestID()
    var coordinatesList = [CLLocation]()
    var videocoordinatesList = [CLLocation]()
    var appDelegate: AppDelegate?
    var model = UserModel.shared
    var previousLocation : CLLocation!
    var polyLines = [MKPolygon]()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
        getCurrentLocation()
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate = delegate
        }
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DriveViewController.driveStartClick(_:))))
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        initViews()
        self.btnSave.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
    }
    
    @IBAction func ActionClear(_ sender: UIButton) {
        initViews()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == SAVE_DRIVE_IDENTIFIER {
                if let dvc = segue.destination as? SaveDriveTableViewController {
                    dvc.startTime = self.startTime
                    dvc.endTime = self.endTime
                    dvc.coordinateList = self.coordinatesList
                    dvc.mapImage = self.snapShotImage
                    dvc.distance = self.distance
                    if isVideoCaptured {
                        dvc.videoPath = self.videoSavePath
                    }
                }
            }
        }
    }
    
    // MARK: Helper Methods
    func initViews() {
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.removeOverlays(self.mapView.overlays)
        mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    self.latitude = location!.coordinate.latitude
                    self.longitude = location!.coordinate.longitude
                    self.showLocationOnMap(lat: self.latitude, lng: self.longitude)
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
    func showDialogToCaptureMapImage() {
        let alert = UIAlertController(title: "Map Image Capture", message: "Do you want to capture map image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.btnSave.isHidden = false
            
        }))
//        
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
//            self.saveMapImage()
//            
//        }))
//
        present(alert, animated: true, completion: nil)
        
    }
    

    
    @IBAction func ActionSave(_ sender: UIButton) {
        saveMapImage()
    }
    
    func showLocationOnMap(lat: Double, lng: Double) {
        let location = CLLocationCoordinate2DMake(lat, lng)
        let region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.03, 0.03))
        let adjustRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(adjustRegion, animated: true)
    }
    
    func showDialogToCaptureVideo() {
        let alert = UIAlertController(title: "Video Recording", message: "Do you want to record video of this drive? Maximum duration of video is 7 minutes", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.presentVideoCaptureController()

        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func presentVideoCaptureController() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                self.imagePicker.sourceType = .camera
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.imagePicker.cameraCaptureMode = .video
                self.imagePicker.videoQuality = .type640x480
                self.imagePicker.allowsEditing = true
                self.imagePicker.videoMaximumDuration = 7 * 60 // 7 Mins durations
                self.imagePicker.delegate = self

                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UIUtil.showMessage(title: "Rear camera doesn't exist", message: "Application cannot access the camera.", controller: self, okHandler: nil)
            }
        } else {
            UIUtil.showMessage(title: "Camera inaccessable", message: "Application cannot access the camera.", controller: self, okHandler: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func driveStartClick(_ sender: Any) {
        if isTracking {
            endTime = Date()
            imageView.image = #imageLiteral(resourceName: "ic_start")
            driveStartButton.setTitle("Start".uppercased(), for: .normal)
            isTracking = false
            appDelegate?.stopContinuousLocation(locationManager: self.locationManager, requestId: self.locationRequestId)
            addAnnotationsOnMap(locationToPoint: self.coordinatesList.last!,title: "End")
            self.btnSave.isHidden = false
            print(self.coordinatesList)
            showDialogToCaptureMapImage()
        }else {
            mapView.removeOverlays(self.mapView.overlays)
            mapView.removeAnnotations(self.mapView.annotations)
            self.coordinatesList = [CLLocation]()
            self.videocoordinatesList = [CLLocation]()
            self.locationRequestId = appDelegate!.startRetrievingContinuousLocation(locationManager: locationManager, block: { (location) in
                print(location)
                var oldLocation: CLLocation
                if self.coordinatesList.count == 0{
                     oldLocation = location
                }else{
                     oldLocation = self.coordinatesList.last!
                }
                self.showLocation(newLocation: location, fromLocation: oldLocation)
                self.coordinatesList.append(location)
                if self.isVideoRecording == true {
                    self.videocoordinatesList.append(location)
                }
                if self.coordinatesList.count == 1 {
                    self.addAnnotationsOnMap(locationToPoint: location, title: "Start")
                }
                self.showLocationOnMap(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            })
            isVideoCaptured = false
            videoSavePath = URL(string: "")
            self.btnSave.isHidden = true
            
            self.showDialogToCaptureVideo()
            imageView.image = #imageLiteral(resourceName: "ic_finish")
            driveStartButton.setTitle("Finish".uppercased(), for: .normal)
            isTracking = true
            startTime = Date()
        }
    }

    func saveMapImage(){
        let snapshotterOptions = MKMapSnapshotOptions()
        snapshotterOptions.region = mapView.region
        snapshotterOptions.scale = UIScreen.main.scale
        snapshotterOptions.size = mapView.frame.size
        
        let snapshotter = MKMapSnapshotter(options: snapshotterOptions)
        
        snapshotter.start() {
            snapshot, error in
            
            let image = snapshot?.image
            
            let finalImageRect = CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!)
            let pinstartImage = UIImage(named: "red_maker")
            let pinendImage = UIImage(named: "blue_maker")
            UIGraphicsBeginImageContextWithOptions((image?.size)!, true, (image?.scale)!);
            image?.draw( at:CGPoint(x: 0, y: 0))
            let size = pinstartImage?.size
            let startPoint = (snapshot?.point(for: (self.coordinatesList.first?.coordinate)!))! as CGPoint
            let endPoint = (snapshot?.point(for: (self.coordinatesList.last?.coordinate)!))! as CGPoint
            pinstartImage?.draw(at: CGPoint(x: startPoint.x, y:startPoint.y - (size?.height)!))
            pinendImage?.draw(at: CGPoint(x: endPoint.x, y:endPoint.y - (size?.height)!))
            
            // draw polygon
            let path = UIBezierPath()
            self.distance = 0
            var firstPoint: CLLocation = CLLocation(latitude: 0, longitude: 0)
            var secondPoint : CLLocation
            var clDistance : CLLocationDistance = 0
            for (i, coordinate) in self.coordinatesList.enumerated() {
                let point = snapshot?.point(for: coordinate.coordinate)
                if i == 0{
                    firstPoint = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
                }else{
                    secondPoint = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
                    clDistance += firstPoint.distance(from: secondPoint)
                    print("\(firstPoint), \(secondPoint), \(clDistance)")
                    firstPoint = secondPoint
                }
                if (finalImageRect.contains(point!)) {
                    if i == 0 {
                        path.move(to: point!)
                    } else {
                        path.addLine(to: point!)
                    }
                }
            }
            self.distance = clDistance
            UIColor.blue.withAlphaComponent(0.7).setStroke()
            path.lineWidth = 2.0
            path.stroke()
            
            let path1 = UIBezierPath()
            if self.isVideoCaptured == true {
                for (i, coordinate) in self.videocoordinatesList.enumerated() {
                    let point = snapshot?.point(for: coordinate.coordinate)
                    if i == 0{
                        firstPoint = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
                    }else{
                        secondPoint = CLLocation(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
                        print("\(firstPoint), \(secondPoint), \(clDistance)")
                        firstPoint = secondPoint
                    }
                    if (finalImageRect.contains(point!)) {
                        if i == 0 {
                            path1.move(to: point!)
                        } else {
                            path1.addLine(to: point!)
                        }
                    }
                }
                UIColor.red.withAlphaComponent(0.7).setStroke()
                path1.lineWidth = 2.0
                path1.stroke()

            }

            
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.snapShotImage = finalImage
            self.performSegue(withIdentifier: self.SAVE_DRIVE_IDENTIFIER, sender: self)

        }
    }
    
    func showLocation(newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        //drawing path or route covered
        //calculation for location selection and pointing annotation
        if (previousLocation as CLLocation?) != nil{
            //case if previous location exists
           if previousLocation.distance(from: newLocation) > 1 {
                previousLocation = newLocation
            }
        }else{
            //in case previous location doesn't exist
            if self.coordinatesList.count == 1 {
                addAnnotationsOnMap(locationToPoint: newLocation, title: "Start")
            }
            previousLocation = newLocation
        }
        
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            mapView.add(polyline)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.blue
            if isVideoRecording == true {
                polylineRenderer.strokeColor = UIColor.red
            }
            polylineRenderer.lineWidth = 2
            
        }
        return polylineRenderer
    }
    
    func addAnnotationsOnMap(locationToPoint : CLLocation, title: String){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        annotation.title = title
        self.mapView.addAnnotation(annotation)
//        let geoCoder = CLGeocoder ()
//        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
//            if placemarks != nil {
//                let placemarks = placemarks! as [CLPlacemark]
//                if  placemarks.count > 0 {
//                    let placemark = placemarks[0]
//                    var addressDictionary = placemark.addressDictionary;
//                    annotation.title = addressDictionary?["Name"] as? String
//                    self.mapView.addAnnotation(annotation)
//                }
//            }
//        })
    }
    

}
//
//extension UIImagePickerController {
//
//    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        return .landscapeLeft
//    }
//}
extension DriveViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedVideo = (info[UIImagePickerControllerMediaURL] as? URL) {
//            videodata = try? Data(contentsOf: pickedVideo, options: .mappedIfSafe)
            self.videoSavePath = pickedVideo
            isVideoCaptured = true
//            self.callCreateTrack(videoname: self.videoSavePath as String)
            
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func callCreateTrack(videoname: String) {
        let start_loc = self.coordinatesList.first! as CLLocation
        let end_loc = self.coordinatesList.last! as CLLocation
        let start_lat = String(start_loc.coordinate.latitude)
        let end_lat = String(end_loc.coordinate.latitude)
        let start_lng = String(start_loc.coordinate.longitude)
        let end_lng = String(end_loc.coordinate.longitude)
        let userid = model.userid()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let starttime = dateFormatter.string(from:self.startTime)
        let endtime = dateFormatter.string(from:self.endTime)
        let params = [
            URLConstant.Param.TAG: "newtrack",
            "trackname" : "testtrack",
            "starttime" : starttime,
            "endtime" : endtime,
            "startloc" : "startlocation",
            "endloc" : "endlocation",
            "creatorid" : userid,
            "startlat" : start_lat,
            "startlng" : start_lng,
            "endlat" : end_lat,
            "endlng" : end_lng
        ] as [String : String]
        
        DispatchQueue.global(qos: .userInitiated).async {
//            let video = try! Data(contentsOf: URL(string : videoname)! as URL)
            DispatchQueue.main.async {
                UIUtil.showProcessing(message: "Please wait")
                WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.CREATE_TRACK, params: params, video: self.videodata!, imageParam: "video", success: { (response) in
                    UIUtil.hideProcessing()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                            let count = Int(json["mycars"] as! Int64)
                            self.model.mycars(String(count))
                            let count1 = Int(json["mydrives"] as! Int64)
                            self.model.mydrives(String(count1))
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

    }
    
    
/*    func addAnnotationsOnMap(locationToPoint : CLLocation){
        //calculation for location selection and pointing annotation
        if let previousLocationNew = previousLocation as CLLocation?{
            //case if previous location exists
            if previousLocation.distanceFromLocation(newLocation) > 200 {
                addAnnotationsOnMap(newLocation)
                previousLocation = newLocation
            }
        }else{
            //in case previous location doesn't exist
            addAnnotationsOnMap(newLocation)
            previousLocation = newLocation
        }    }
*/

}


extension AppDelegate {
    func startRetrievingContinuousLocation(locationManager: INTULocationManager,block: @escaping (_ location: CLLocation)->Void) -> INTULocationRequestID {
        return locationManager.subscribeToLocationUpdates(withDesiredAccuracy: .room) { (location, accuracy, status) in
            if let location = location {
                block(location)
            }
        }
    }
    
    func stopContinuousLocation(locationManager: INTULocationManager,requestId: INTULocationRequestID) {
        locationManager.cancelLocationRequest(requestId)
    }
}

