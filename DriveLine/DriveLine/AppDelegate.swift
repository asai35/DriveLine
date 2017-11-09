//
//  AppDelegate.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import INTULocationManager
import UserNotifications
import UserNotificationsUI

let SharedAppDelegate = UIApplication.shared.delegate as! AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var trackid: Int = 0
    var driveid: Int = 0
    var videolink: String?
    var badgeNumber = 0
    var model = UserModel.shared
    var lat: Double = 0.0
    var lng: Double = 0.0
    var locationRequestId = INTULocationRequestID()
    let locationManager = INTULocationManager.sharedInstance()
    var uploadTimer = Timer()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .default
        
        UIApplication.shared.isIdleTimerDisabled = true
        trackid = 0;
        driveid = 0;
        videolink = ""

        if UserDefaults.standard.value(forKey: "loggedin") != nil {
            if UserDefaults.standard.bool(forKey: "loggedin")  == true{
                self.callLoginAPI(model.useremail(), password: model.userpassword())
            }
        }
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            self.registerForPushNotifications()
            // For iOS 10 data message (sent via FCM
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        //        NotificationCenter.default.addObserver(self, selector: #selector(tokenRereshNotification(_:)),
        //                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        UIApplication.shared.registerForRemoteNotifications()
        Util.copyFile(fileName: "drive.sqlite")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Entered Background")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Entered Foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.portrait
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return self.orientationLock
//    }
    // MARK: - Pushnotification
    func registerForPushNotifications(){

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                print("Permission granted: \(granted)")

                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            // Fallback on earlier versions
        }

    }

    func getNotificationSettings(){

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            // Fallback on earlier versions
        }

    }
    func tokenRereshNotification(_ notification: Notification) {

    }
    //MARK: REMOTE NOTIFICATION HANDLING

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let settings = UIUserNotificationSettings(types:[.alert,.badge,.sound], categories: nil)

        UIApplication.shared.registerUserNotificationSettings(settings)

        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        if !deviceTokenString.isEmpty {
            NSLog("DEVICE TOKEN : %@",deviceTokenString);
            NotificationHandler.sharedInstance.deviceToken = deviceTokenString
            model.deviceToken(deviceTokenString)

        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("Notification Registration Failed \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        let state: UIApplicationState = UIApplication.shared.applicationState

        if state != .active {
            NotificationHandler.sharedInstance.handleNotificaTion(WithPayload:userInfo["aps"]! as! [String : AnyObject])
        }
    }
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("backgroundfetch")

        print("\(userInfo)")
        if let apns = userInfo["aps"] as? [String: AnyObject] {

            self.badgeNumber = apns["badge"] as! Int
            UIApplication.shared.applicationIconBadgeNumber = self.badgeNumber
//            let viewController = self.window?.rootViewController
//            let actionSheet = UIAlertController(title: "DriveLine", message:  alert, preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//            actionSheet.addAction(alertAction)
//
//            viewController?.present(actionSheet, animated: true, completion: nil)
        }

        completionHandler(.newData)
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("presentation")

        print(userInfo)
        if let apns = userInfo["aps"] as? [String: AnyObject] {
            self.badgeNumber = apns["badge"] as! Int
            UIApplication.shared.applicationIconBadgeNumber = 0

            let viewController = self.window?.rootViewController
            if let nav = viewController?.navigationController {
                if nav.isMember(of: UITabBarController.self) {
                    let tab = nav.tabBarController?.tabBar.items?[3]
                    if self.badgeNumber == 0 {
                        tab?.badgeValue = "\(self.badgeNumber)"
                        tab?.badgeColor = .red
                    }else {
                        tab?.badgeValue = ""
                        tab?.badgeColor = .clear
                    }
                }
            }
//            let actionSheet = UIAlertController(title: "DriveLine", message:  alert , preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//            actionSheet.addAction(alertAction)
//
//            viewController?.present(actionSheet, animated: true, completion: nil)

        }


        completionHandler([.alert , .badge ,.sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("response")

        print(userInfo)
        if let apns = userInfo["aps"] as? [String: AnyObject] {
            self.badgeNumber = apns["badge"] as! Int
            if (apns["type"] as! String) == "5" || (apns["type"] as! String) == "6" {
                model.followers(apns["followers"] as! String)
            }
            if (apns["type"] as! String) == "6" {
                return
            }
            UIApplication.shared.applicationIconBadgeNumber = self.badgeNumber

            let viewController = self.window?.rootViewController
            if let nav = viewController?.navigationController {
                if nav.isMember(of: UITabBarController.self) {
                    let tab = nav.tabBarController?.tabBar.items?[3]
                    if self.badgeNumber == 0 {
                        tab?.badgeValue = "\(self.badgeNumber)"
                        tab?.badgeColor = .red
                    }else {
                        tab?.badgeValue = ""
                        tab?.badgeColor = .clear
                    }
                }
            }
//            let viewController = self.window?.rootViewController
//            let actionSheet = UIAlertController(title: "DriveLine", message:  alert , preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//            actionSheet.addAction(alertAction)
//
//            viewController?.present(actionSheet, animated: true, completion: nil)

        }
        
        completionHandler()
    }

    // MARK: API Calls
    func callLoginAPI(_ email: String, password: String) {
        var params = [
            URLConstant.Param.TAG: "login",
            URLConstant.Param.EMAIL: email,
            URLConstant.Param.PASSWORD: password
        ]
        if model.deviceToken() != "" {
            params["device_token"] = model.deviceToken()
        }
        if LocationManager.sharedInstance.currentLocation?.latitude != nil && LocationManager.sharedInstance.currentLocation?.longitude != nil {

            params["latitude"] = "\(LocationManager.sharedInstance.currentLocation!.latitude)"
            params["longitude"] = "\(LocationManager.sharedInstance.currentLocation!.longitude)"
        }

        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.LOGIN, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    let user: UserModel = UserModel.init(object: ["email" : json["email"] as! String, "password": password])
                    user.drive_count = json["mydrives"] as! String
                    user.userfollowers = json["followers"] as! String
                    user.ride_count = json["mycars"] as! String
                    user.photourl = json["photo_url"] as? String
                    user.user_id = json["user_id"] as? String
                    user.name = json["name"] as? String
                    user.point = json["points"] as? String
                    user.badge = Int(json["badge_number"] as! String)
                    self.model.saveUserdata(user: user)

                    UIApplication.shared.applicationIconBadgeNumber = 0

                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "tabVC")
                    (self.window?.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
                }else {
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    func setTimer(){
        uploadTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(AppDelegate.uploadDrive), userInfo: nil, repeats: true)
    }

    func endTimer(){
        self.uploadTimer.invalidate()
    }

    func uploadDrive() {
        let driveDatas = ModelManager.getInstance().getAllDriveData()
        if driveDatas.count > 0 {
            let driveData = driveDatas.firstObject as! DataModel
            var params = [String: Any]()
            let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = driveData.driveimage.components(separatedBy: "/").last
            let imagefilepath = filepath.appendingPathComponent(filename!)
            let driveImage = UIImage(contentsOfFile: imagefilepath.path)
            let waypointfileName = filepath.appendingPathComponent(driveData.waypoints)
            let waypoints = NSArray.init(contentsOf: waypointfileName)


                params = [
                    URLConstant.Param.TAG: "newdrive",
                    "drivename" : driveData.drivename,
                    "starttime" : driveData.starttime,
                    "endtime" : driveData.endtime,
                    "startloc" : driveData.startloc,
                    "endloc" : driveData.endloc,
                    "driverID" : driveData.driverID,
                    "startlat" : driveData.startlat,
                    "startlng" : driveData.startlng,
                    "endlat" : driveData.endlat,
                    "endlng" : driveData.endlng,
                    "waypoints" : waypoints ?? "",
                    "videourl" : driveData.videourl,
                    "thumburl" : driveData.thumburl,
                    "videoid" : driveData.videoid,
                    "waylength" : driveData.waylength,
                    "trackID" : "",
                    "screentype" : driveData.screentype
                    ] as [String : Any]
            print (params)
            WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.CREATE_DRIVE, params: params, image: driveImage, imageParam: "image",  success: { (response) in
                UIUtil.hideProcessing()
                if let json = response as? NSDictionary {
                    if WebserviceUtil.isStatusOk(json: json) {
                        self.model.userpoint("\(json.object(forKey: "points") as! Int)")
                        let deleteDrive = ModelManager.getInstance().deleteDriveData(dataInfo: driveData)
                        self.showLocalNotification()
                        print(deleteDrive)
                        if ModelManager.getInstance().getAllDriveData().count == 0 {
                            self.uploadTimer.invalidate()
                        }
                    }else {
                        UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    }
                    print(json)
                }

            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

    func showLocalNotification() {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "DriveLine"
            content.body = "One drive uploaded successfully."
            content.sound = UNNotificationSound.default()

            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let notificationRequest = UNNotificationRequest(identifier: "uploadSuccess", content: content, trigger: notificationTrigger)

            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
                if let error = error {
                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

    }
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
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

