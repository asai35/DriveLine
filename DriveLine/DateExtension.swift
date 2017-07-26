
//
//  DateExtension.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/21/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import Foundation

extension Date {
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
extension String{
    
    func FeedDate() -> String {
        return retrivePostTime(postDate: self)
    }
    
    func retrivePostTime(postDate: String) -> String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        df.timeZone = NSTimeZone(abbreviation: "PST") as TimeZone!
        let userPostdate : Date = df.date(from: postDate)!
        let currentDate : Date = Date()
        let distanceBetweenDates: TimeInterval = currentDate.timeIntervalSince(userPostdate as Date)
        let theTimeInterval: TimeInterval = distanceBetweenDates
        let sysCalendar: Calendar = Calendar.current as Calendar
        let date1: Date = Date()
        let date2: Date = Date(timeInterval: theTimeInterval, since: date1 as Date)
        let flag = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        let conversionInfo: DateComponents = sysCalendar.dateComponents(flag, from: date1, to: date2)
        
        var returnDate: String = ""
        if conversionInfo.year! > 0 {
            let dfs: DateFormatter = DateFormatter()
            dfs.dateFormat = "YYYY/MM/dd"
            dfs.timeZone = NSTimeZone(abbreviation: "PST") as TimeZone!
            let userPostdate : Date = df.date(from: postDate)!
            returnDate = dfs.string(from: userPostdate)
        }else if conversionInfo.month! > 0 {
            if conversionInfo.month == 1{
                returnDate = String(format: "%ld month", conversionInfo.month!)
            }else{
                returnDate = String(format: "%ld months", conversionInfo.month!)
            }
        }else if conversionInfo.day! > 0 {
            if conversionInfo.day == 1{
                returnDate = String(format: "%ld day", conversionInfo.day!)
            }else{
                returnDate = String(format: "%ld days", conversionInfo.day!)
            }
        }
        else if conversionInfo.hour! > 0 {
            if conversionInfo.hour == 1{
                returnDate = String(format: "%ld hour", conversionInfo.hour!)
            }else{
                returnDate = String(format: "%ld hours", conversionInfo.hour!)
            }
        }
        else if conversionInfo.minute! > 0 {
            if conversionInfo.minute == 1{
                returnDate = String(format: "%ld minute", conversionInfo.minute!)
            }else{
                returnDate = String(format: "%ld minutes", conversionInfo.minute!)
            }
        }
        else  {
            returnDate = String(format: "now")
        }
        
        return returnDate
    }
}
