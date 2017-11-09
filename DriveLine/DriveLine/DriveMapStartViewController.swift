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
    var startlatitude = 0.0
    var startlongitude = 0.0
    var myDrive: NSDictionary = NSDictionary.init()
    var wayPoints = [NSDictionary]()
    var startPosition = CLLocationCoordinate2D()
    var endPosition = CLLocationCoordinate2D()
    var previousLocation : CLLocation!
    var fitMap: Bool = true
    var isTrack = false
    var isCenter = false
    @IBOutlet weak var btnCenter: UIButton!

    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
//        getDriveDetail()
        initViews()
        
    }
    
    // MARK: Helper Methods
    func initViews() {
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        self.playButton.isHidden = true
        mapView.delegate = self
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate = delegate
        }
        self.showMapStartEndPin()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate?.stopContinuousLocation(locationManager: self.locationManager, requestId: self.locationRequestId)

    }

    func getCurrentLocation() {
        locationManager.requestLocation(withDesiredAccuracy: .room, timeout: 3.0) { (location, accuracy, status) in
            switch (status) {
            case .success, .timedOut:
                if location != nil {
                    self.latitude = location!.coordinate.latitude
                    self.longitude = location!.coordinate.longitude
                    self.drawRoute()
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

    func getDirection() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: startPosition.latitude, longitude: startPosition.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        print(startPosition.latitude)
        print(startPosition.longitude)
        print(self.latitude)
        print(self.longitude)
        directions.calculate {  response, error in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

            let route = response.routes[0]
            route.polyline.title = "Apple"
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            if self.fitMap {
                self.fitMap = false
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            if self.isCenter == true {
                self.showLocationOnMap(lat: self.latitude, lng: self.longitude)
            }
        }

    }

    @IBAction func fitMapView(_ sender: UIButton) {
        if self.fitMap {
            self.fitMap = false
        }else{
            fitMap = true
            self.isCenter = false
        }
    }
    func showLocationOnMap(lat: Double, lng: Double) {
        let location = CLLocationCoordinate2DMake(lat, lng)
        let region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.03, 0.03))
        let adjustRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(adjustRegion, animated: true)
    }
  
    // MARK: IBActions
    func drawRoute() {
        var isLocationstart: Bool = false
        self.locationRequestId = appDelegate!.startRetrievingContinuousLocation(locationManager: locationManager, block: { (location) in
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            print(location)
//            self.mapView.removeOverlays(self.mapView.overlays)
//            self.mapView.removeAnnotations(self.mapView.annotations)


            if self.isTrack {
                if isLocationstart == true {
                    var oldLocation: CLLocation
                    if self.coordinatesList.count == 0{
                        oldLocation = location
                    }else{
                        oldLocation = self.coordinatesList.last!
                    }
                    self.showLocation(newLocation: location, fromLocation: oldLocation)
                    self.coordinatesList.append(location)
                    self.showMapPolyLine()
                }else{
                    isLocationstart = true
                }
            }
            if fabs(self.latitude - self.startPosition.latitude) < 0.0005 && fabs(self.longitude - self.startPosition.longitude) < 0.0005 {
                self.playButton.isHidden = false
            }
            self.showMapPolyLine()
            if self.playButton.isHidden {
                self.getDirection()
            }
            if self.isCenter {
                self.showLocationOnMap(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            }
        })
    }


    @IBAction func ActionCenter(_ sender: UIButton) {
        if isCenter == true {
            isCenter = false
        }else{
            isCenter = true
            self.fitMap = false
        }
    }
    // MARK: IBActions
    @IBAction func playClick(_ sender: Any) {
        if isTrack {
            playButton.setImage(#imageLiteral(resourceName: "ic_start"), for: .normal)
            isTrack = false
        }else{
            playButton.setImage(#imageLiteral(resourceName: "ic_finish"), for: .normal)
            isTrack = true
        }
    }

    func driveStop() {
        playButton.setImage(#imageLiteral(resourceName: "ic_start"), for: .normal)
        isTrack = false
    }

    func driveStart()  {
        playButton.setImage(#imageLiteral(resourceName: "ic_finish"), for: .normal)
        isTrack = true
   }

    func showLocation(newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        if (previousLocation as CLLocation?) != nil{
            if previousLocation.distance(from: newLocation) > 1 {
                previousLocation = newLocation
            }
        }else{
            previousLocation = newLocation
        }

        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            polyline.title = "userTrack"
            mapView.add(polyline)

        }
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
                    self.showMapStartEndPin()

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
                startPosition = info1.coordinate
                info1.title = "Start Point"
                info1.imageName = "start_flag"
                annotations.append(info1)
            }

            if i == wayPoints.count - 2 {
                let info2 = CustomPointAnnotation()
                info2.coordinate = CLLocationCoordinate2DMake(pplat!, pplng!)
                info2.title = "End Point"
                endPosition = info2.coordinate
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

    func showMapStartEndPin() {

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
                startPosition = info1.coordinate
                info1.title = "Start Point"
                info1.imageName = "start_flag"
                annotations.append(info1)
            }

            if i == wayPoints.count - 2 {
                let info2 = CustomPointAnnotation()
                info2.coordinate = CLLocationCoordinate2DMake(pplat!, pplng!)
                info2.title = "End Point"
                endPosition = info2.coordinate
                info2.imageName = "end_flag"
                annotations.append(info2)
            }

        }

        self.mapView.addAnnotations(annotations)
        self.getCurrentLocation()

    }

    //MARK:- MapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if overlay.title! == "Apple" {
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 1
        }else if overlay.title! == "userTrack" {
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3
        }else {
            polylineRenderer.strokeColor = UIColor.green
            polylineRenderer.lineWidth = 2
        }
        return polylineRenderer
    }

    func zoomToRegion(_ lat: Double, _ lng: Double) {
        if self.fitMap {
            self.fitMap = false
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)

            let region = MKCoordinateRegionMakeWithDistance(location, 5000.0, 7000.0)

            mapView.setRegion(region, animated: true)
        }
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
