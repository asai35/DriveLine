//
//  URLConstant.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/24/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import Foundation

@objc protocol AlertControllerProtocol {

    @objc optional func closeAction()
}
protocol LocationManagerProtocol {

    func didUpdateLocation()
}

class URLConstant {
    
    class API {
//        static let BASE_URL = "http://driveline.sandboxserver.co.za"
        static let BASE_URL = "https://driveline.club/driveline/api"
//        static let BASE_URL = "https://api.driveline.club"
        static let REGISTER = "\(BASE_URL)/R_register.php"
        static let LOGIN = "\(BASE_URL)/R_login.php"
        static let FORGOT = "\(BASE_URL)/R_forgot_password.php"
        static let RESET = "\(BASE_URL)/R_reset_password.php"
        static let CREATE_DRIVE = "\(BASE_URL)/R_newDrive.php"
        static let UPLOAD_VIDEO = "\(BASE_URL)/youtube/upload_to_youtube.php"
        static let GET_TRACKSHOW = "\(BASE_URL)/R_trackShow.php"
        static let GET_TRACKCOMMENTS = "\(BASE_URL)/R_getComment.php"
        static let ADD_TRACKCOMMENTS = "\(BASE_URL)/R_addTrackComment.php"
        static let ADD_TRACKLIKE = "\(BASE_URL)/R_addTrackLike.php"
        static let ADD_DRIVELIKE = "\(BASE_URL)/R_NewLikes.php"
        static let DELETE_DRIVE = "\(BASE_URL)/R_deleteDrive.php"
        static let ADD_DRIVECOMMENTS = "\(BASE_URL)/R_newDiscussion.php"
        static let GET_DRIVECOMMENTS = "\(BASE_URL)/R_getDriveComment.php"
        static let ADD_MYRIDES = "\(BASE_URL)/R_newRide.php"
        static let EDIT_RIDE = "\(BASE_URL)/R_editCar.php"
        static let UPLOAD_USER_PHOTO = "\(BASE_URL)/R_userphoto.php"
        static let DELETE_RIDE = "\(BASE_URL)/R_deleteCar.php"
        static let GET_MYRIDES = "\(BASE_URL)/R_RideAllShow.php"
        static let GET_MYDRIVE = "\(BASE_URL)/R_showMyDrive.php"
        static let ADD_NEWRIDE = "\(BASE_URL)/R_newRide.php"
        static let CREATE_TRACK = "\(BASE_URL)/R_createTrack.php"
        static let SEARCH_DRIVE = "\(BASE_URL)/R_searchDrive.php"
        static let GET_DRIVEDETAIL = "\(BASE_URL)/R_getDriveDetail.php"
        static let GETALLNEWS = "\(BASE_URL)/R_getAllNews.php"
        static let SHARE = "\(BASE_URL)/R_Share.php"
        static let JOIN_EVENT = "\(BASE_URL)/R_joinEvent.php"
        static let USER_EVENT = "\(BASE_URL)/R_getUserEvent.php"
        static let NOTIFICATION = "\(BASE_URL)/R_Notification.php"
        static let FOLLOW = "\(BASE_URL)/R_Follow.php"
        static let USER_PROFILE = "\(BASE_URL)/R_userProfile.php"
    }
    
    class Param {
        static let TAG = "tag"
        static let PAGE = "page"
        static let USERNAME = "username"
        static let NAME = "name"
        static let EMAIL = "email"
        static let PASSWORD = "password"
        static let MOBILE = "mobile"
        static let STARTLOC = "startloc"
        static let ENDLOC = "endloc"
        static let STARTLAT = "startlat"
        static let STARTLNG = "startlng"
        static let ENDLAT = "endlat"
        static let ENDLNG = "endlng"
        static let STARTTIME = "starttime"
        static let ENDTIME = "endtime"
        static let COMMENT = "comment"
        static let LIKE = "like"
        static let TRACKID = "track_id"
        static let CREATORID = "creator_id"
        static let DRIVERID = "driverID"
        static let lIKE_COUNT = "like_count"
        static let COMMENT_COUNT = "comment_count"
        static let TRACK_NAME = "trackname"
        static let VIDEO = "video"
        static let THUMB = "thumb"
        static let YEAR = "year"
        static let RIDEID = "ride_id"
        static let MAKE = "make"
        static let MODEL = "model"
        static let USERID = "userid"
        static let CAR = "car"

    }
}
