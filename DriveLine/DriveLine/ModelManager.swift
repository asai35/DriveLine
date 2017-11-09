//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil

    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Util.getPath(fileName: "drive.sqlite"))
        }
        return sharedInstance
    }
    func addDriveData(dataInfo: DataModel) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO drive_info (tag, drivename, starttime, endtime, startloc, endloc, driverID, startlat, startlng, endlat, endlng, waypoints, videourl, thumburl, videoid, waylength, screentype, create_date, trackID, driveimage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [dataInfo.tag, dataInfo.drivename, dataInfo.starttime, dataInfo.endtime, dataInfo.startloc, dataInfo.endloc, dataInfo.driverID, dataInfo.startlat, dataInfo.startlng, dataInfo.endlat, dataInfo.endlng, dataInfo.waypoints, dataInfo.videourl, dataInfo.thumburl, dataInfo.videoid, dataInfo.waylength, dataInfo.screentype, dataInfo.createdate, dataInfo.trackID, dataInfo.driveimage])
        sharedInstance.database!.close()
        return isInserted
    }
   
    func updateDriveData(dataInfo: DataModel) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE drive_info SET drivename=?, driverID=? WHERE No=?", withArgumentsIn: [dataInfo.drivename, dataInfo.driverID, dataInfo.driveNumber])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteDriveData(dataInfo: DataModel) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM drive_info WHERE No=?", withArgumentsIn: [dataInfo.driveNumber])
        sharedInstance.database!.close()
        return isDeleted
    }

    func getAllDriveData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM drive_info", withArgumentsIn: nil)
        let marrDriveInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let dataInfo : DataModel = DataModel()
                dataInfo.driveNumber = Int(resultSet.int(forColumn: "No"))
                dataInfo.drivename = resultSet.string(forColumn: "drivename")
                dataInfo.startloc = resultSet.string(forColumn: "startloc")
                dataInfo.startlng = resultSet.string(forColumn: "startlng")
                dataInfo.starttime = resultSet.string(forColumn: "starttime")
                dataInfo.endtime = resultSet.string(forColumn: "endtime")
                dataInfo.driverID = resultSet.string(forColumn: "driverID")
                dataInfo.startlat = resultSet.string(forColumn: "startlat")
                dataInfo.startlng = resultSet.string(forColumn: "startlng")
                dataInfo.endlat = resultSet.string(forColumn: "endlat")
                dataInfo.endlng = resultSet.string(forColumn: "endlng")
                dataInfo.waypoints = resultSet.string(forColumn: "waypoints")
                dataInfo.videourl = resultSet.string(forColumn: "videourl")
                dataInfo.videoid = resultSet.string(forColumn: "videoid")
                dataInfo.thumburl = resultSet.string(forColumn: "thumburl")
                dataInfo.waylength = resultSet.string(forColumn: "waylength")
                dataInfo.screentype = resultSet.string(forColumn: "screentype")
                dataInfo.createdate = resultSet.string(forColumn: "create_date")
                dataInfo.driveimage = resultSet.string(forColumn: "driveimage")
                dataInfo.trackID = ""
                marrDriveInfo.add(dataInfo)
            }
        }
        sharedInstance.database!.close()
        return marrDriveInfo
    }
    func getOneDriveData() -> DataModel {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM drive_info", withArgumentsIn: nil)
        let dataInfo : DataModel = DataModel()
        if (resultSet != nil) {
            while resultSet.next() {
                dataInfo.driveNumber = Int(resultSet.int(forColumn: "No"))
                dataInfo.drivename = resultSet.string(forColumn: "drivename")
                dataInfo.startloc = resultSet.string(forColumn: "startloc")
                dataInfo.startlng = resultSet.string(forColumn: "startlng")
                dataInfo.starttime = resultSet.string(forColumn: "starttime")
                dataInfo.endtime = resultSet.string(forColumn: "endtime")
                dataInfo.driverID = resultSet.string(forColumn: "driverID")
                dataInfo.startlat = resultSet.string(forColumn: "startlat")
                dataInfo.startlng = resultSet.string(forColumn: "startlng")
                dataInfo.endlat = resultSet.string(forColumn: "endlat")
                dataInfo.endlng = resultSet.string(forColumn: "endlng")
                dataInfo.waypoints = resultSet.string(forColumn: "waypoints")
                dataInfo.videourl = resultSet.string(forColumn: "videourl")
                dataInfo.videoid = resultSet.string(forColumn: "videoid")
                dataInfo.thumburl = resultSet.string(forColumn: "thumburl")
                dataInfo.waylength = resultSet.string(forColumn: "waylength")
                dataInfo.screentype = resultSet.string(forColumn: "screentype")
                dataInfo.createdate = resultSet.string(forColumn: "create_date")
                dataInfo.driveimage = resultSet.string(forColumn: "driveimage")
                dataInfo.trackID = ""
                break
            }
        }
        sharedInstance.database!.close()
        return dataInfo
    }
}
