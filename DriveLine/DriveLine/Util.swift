//
//  Util.swift
//  DemoProject
//
//  Created by Krupa-iMac on 24/07/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func getPath(fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        print("url: ", fileURL.path)
        return fileURL.path
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL?.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath!.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            var title : String = ""
            var message : String = ""
            if (error != nil) {
                title = "Error Occured"
                message = (error?.localizedDescription)!
            } else {
                title = "Successfully Copy"
                message = "Your database copy successfully"
            }
            let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            SharedAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    class func invokeAlertMethod(strTitle: String, strBody: String, delegate: AnyObject?) {
        let alert: UIAlertController = UIAlertController.init(title: strTitle, message: strBody, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        SharedAppDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
   
}
