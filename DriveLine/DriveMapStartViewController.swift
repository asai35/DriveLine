//
//  DriveMapStartViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/21/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import MapKit
import INTULocationManager
import MobileCoreServices
import AVKit
import AVFoundation

class DriveMapStartViewController: UIViewController, MKMapViewDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var playButton: UIButton!
    
    var driveid: Int = 0
    let locationManager = INTULocationManager.sharedInstance()
    var imagePicker = UIImagePickerController()
    var locationRequestId = INTULocationRequestID()
    var coordinatesList = [CLLocation]()
    var appDelegate: AppDelegate?
    var model = UserModel.shared
    // MARK: Variables
    var latitude = 0.0
    var longitude = 0.0
    var myDrive: NSDictionary = NSDictionary.init()
    var wayPoints = [NSDictionary]()
//    var startPosition = Point
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getDriveDetail()
        initViews()
        
    }
    
    // MARK: Helper Methods
    func initViews() {
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        
        mapView.delegate = self
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
    func showLocationOnMap(lat: Double, lng: Double) {
        let location = CLLocationCoordinate2DMake(lat, lng)
        let region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.03, 0.03))
        let adjustRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(adjustRegion, animated: true)
    }
  
    // MARK: IBActions
    @IBAction func playClick(_ sender: Any) {
        
    }
    
    func getDriveDetail() {
        let params = [
            URLConstant.Param.TAG: "drivedetail",
            "driveid": driveid
            ] as [String : Any]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.GET_DRIVEDETAIL, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.appDelegate?.stopContinuousLocation(locationManager: self.locationManager, requestId: self.locationRequestId)
                    self.myDrive = (json["result"] as? NSDictionary)!
                    
                    self.showMapPolyLine()
                    
                }else {
                    UIUtil.showToast(message: json.object(forKey: "result") as! String)
                    
                }
                print(json)
            }
        }, failure: { (error) in
            
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        })

    }
    
    func showMapPolyLine() {
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        let wayPoints = myDrive.object(forKey: "waypoints") as! [[String: Any]]
        var annotations = [CustomPointAnnotation]()
        for i in 0..<wayPoints.count {
            if i % 2 == 1 {
                continue
            }
            let wplat = wayPoints[i] as! [String: String]
            let pplat = Double(wplat["lat"]!)
            let wplng = wayPoints[i + 1] as! [String: String]
            let pplng = Double(wplng["lng"]!)
            
            if i == 0 {
                zoomToRegion(pplat!, pplng!)
                let info1 = CustomPointAnnotation()
                info1.coordinate = CLLocationCoordinate2DMake(pplat!, pplng!)
                info1.title = "Start Point"
                info1.imageName = "start_flag"
                annotations.append(info1)
            }
            
            if i == wayPoints.count - 2 {
                let info2 = CustomPointAnnotation()
                info2.coordinate = CLLocationCoordinate2DMake(pplat!, pplng!)
                info2.title = "End Point"
                info2.imageName = "end_flag"
                annotations.append(info2)
            }

            let clPoints = CLLocationCoordinate2D.init(latitude: pplat!, longitude: pplng!)
            points.append(clPoints)
        }
        
        self.mapView.addAnnotations(annotations)
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        
        mapView.add(polyline)

    }
    
    //MARK:- MapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 2
            
        }
        return polylineRenderer
    }
    func zoomToRegion(_ lat: Double, _ lng: Double) {
        
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let region = MKCoordinateRegionMakeWithDistance(location, 5000.0, 7000.0)
        
        mapView.setRegion(region, animated: true)
    }
    //MARK:- Annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        
        return anView
    }
}
