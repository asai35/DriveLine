//
//  UserModel.swift
//  DriveLine
//
//  Created by mac on 5/10/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import SwiftyJSONModel
import SystemConfiguration

class UserModel: NSObject {
    
    enum PropertyKey: String{
        case email, password
    }
    
    static let shared = UserModel()
    
    fileprivate override init(){}
    
    var email : String?
    var password : String?
    var user_id : String?
    var name : String?
    var photourl : String?
    var ride_count : String! = "0"
    var drive_count : String! = "0"
    var userfollowers : String! = "0"
    var point : String! = "100"
    var badge : Int! = 0

    let defaults = UserDefaults.standard
    
    required init(object: NSDictionary) {
        email = object.object(forKey: "email") as! String?
        password = object.object(forKey: "password") as! String?
    }
    
}
extension UserModel {
    
    func userid() -> String {
        if defaults.value(forKey: "user_id") != nil{
            return (defaults.value(forKey: "user_id") as! String?)!
        }else{
            return ""
        }
    }
    
    func useremail() -> String {
        if defaults.value(forKey: "email") != nil{
            return (defaults.value(forKey: "email") as! String?)!
        }else{
            return ""
        }
    }
    
    func username() -> String {
        if defaults.value(forKey: "name") != nil{
            return (defaults.value(forKey: "name") as! String?)!
        }else{
            return ""
        }
    }
    
    func userpoint() -> String {
        if defaults.value(forKey: "points") != nil{
            return (defaults.value(forKey: "points") as! String?)!
        }else{
            return ""
        }
    }
    
    func userpassword() -> String {
        if defaults.value(forKey: "password") != nil{
            return (defaults.value(forKey: "password") as! String?)!
        }else{
            return ""
        }
    }

    func deviceToken() -> String {
        if defaults.value(forKey: "deviceToken") != nil{
            return (defaults.value(forKey: "deviceToken") as! String?)!
        }else{
            return ""
        }
    }

    func deviceToken(_ count : String) {
        defaults.set(count, forKey: "deviceToken")
    }

    func mycars() -> String {
        if defaults.value(forKey: "ride_count") != nil{
            return (defaults.value(forKey: "ride_count") as! String?)!
        }else{
            return "0"
        }
    }
    
    func mydrives(_ count : String) {
        defaults.set(count, forKey: "drive_count")
    }

    func followers(_ count : String) {
        defaults.set(count, forKey: "followers")
    }

    func mycars(_ count : String) {
        defaults.set(count, forKey: "ride_count")
    }
    
    func mydrives() -> String {
        if defaults.value(forKey: "drive_count") != nil{
            return (defaults.value(forKey: "drive_count") as! String?)!
        }else{
            return ""
        }
    }

    func followers() -> String {
        if defaults.value(forKey: "followers") != nil{
            return (defaults.value(forKey: "followers") as! String?)!
        }else{
            return ""
        }
    }

    func userpoint(_ count : String) {
        defaults.set(count, forKey: "points")
    }

    func userbadge(_ count : Int) {
        defaults.set(count, forKey: "badge_number")
    }

    func userbadge() -> Int {
        if defaults.value(forKey: "badge_number") != nil{
            return (defaults.value(forKey: "badge_number") as! Int?)!
        }else{
            return 0
        }
    }

    func photoUrl() -> String {
        if defaults.value(forKey: "photourl") != nil{
            return (defaults.value(forKey: "photourl") as! String?)!
        }else{
            return ""
        }
    }
    func photoUrl(_ url: String) {
        defaults.set(url, forKey: "photourl")
    }
    
    func loadUserdata() -> UserModel {
        let user = UserModel.init(object: ["email": "", "password": ""])
        
        if defaults.value(forKey: "email") != nil{
            user.email = defaults.value(forKey: "email") as! String?
        }
        if defaults.value(forKey: "password") != nil{
            user.password = defaults.value(forKey: "password") as! String?
        }
        if defaults.value(forKey: "user_id") != nil{
            user.user_id = defaults.value(forKey: "user_id") as! String?
        }
        if defaults.value(forKey: "name") != nil{
            user.name = defaults.value(forKey: "name") as! String?
        }
        if defaults.value(forKey: "photourl") != nil{
            user.photourl = defaults.value(forKey: "photourl") as! String?
        }
        if defaults.value(forKey: "drive_count") != nil{
            user.drive_count = defaults.value(forKey: "drive_count") as! String
        }
        if defaults.value(forKey: "followers") != nil{
            user.userfollowers = defaults.value(forKey: "followers") as! String
        }
        if defaults.value(forKey: "ride_count") != nil{
            user.ride_count = defaults.value(forKey: "ride_count") as! String
        }
        
        if defaults.value(forKey: "points") != nil{
            user.point = defaults.value(forKey: "points") as! String
        }
        if defaults.value(forKey: "badge_number") != nil{
            user.badge = defaults.value(forKey: "badge_number") as! Int
        }

        return user
    }
   
    func saveUserdata(user: UserModel) {
        
        if user.email != nil{
            defaults.set(user.email, forKey: "email")
        }
        if user.password != nil{
            defaults.set(user.password, forKey: "password")
        }
        if user.user_id != nil{
            defaults.set(user.user_id, forKey: "user_id")
        }
        if user.name != nil{
            defaults.set(user.name, forKey: "name")
        }
        if user.photourl != nil{
            defaults.set(user.photourl, forKey: "photourl")
        }
        defaults.set(user.drive_count, forKey: "drive_count")
        defaults.set(user.userfollowers, forKey: "followers")
        defaults.set(user.ride_count, forKey: "ride_count")
        defaults.set(user.point, forKey: "points")
        defaults.set(user.badge, forKey: "badge_number")

        defaults.set(true, forKey: "loggedin")
        defaults.synchronize()
    }
}

class DriveData: NSObject {
    dynamic var driveName = ""
    var tag = "newdrive"
    var starttime = ""
    var endtime = ""
    var startlocation = ""
    var endlocation = ""
    var driveId = ""
    var start_lat = ""
    var start_lng = ""
    var end_lat = ""
    var end_lng = ""
    var waypoints = [[String:String]]()
    var videoYoutubeUrl = ""
    var videoThumbYoutubeUrl = ""
    var videoID = ""
    var distance = 0
    var drivestyle = ""
}
