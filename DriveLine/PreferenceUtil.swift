//
//  PreferenceUtil.swift
//  Code Clobber
//
//  Created by Abdul Wahib.
//  Copyright © 2017 CodeClobber. All rights reserved.
//

import Foundation

class PreferenceUtil {
    
    // MARK: Save Values
    class func saveStringToPrefs(key: String, value: String?){
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    class func save(key: String, value: Int){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    class func save(key: String, value: Double){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    class func save(key: String, value: Bool){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    class func save(key: String, value: NSDictionary) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    class func save(key: String, value: NSArray) {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // MARK: Get Values
    class func get(key:String) -> String? {
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    class func getIntFromPrefs(key:String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    class func getDoubleFromPrefs(key:String) -> Double {
        return UserDefaults.standard.double(forKey: key)
    }
    
    class func getBoolFromPrefs(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func getDictionaryFromPrefs(key: String) -> NSDictionary? {
        return UserDefaults.standard.object(forKey: key) as? NSDictionary
    }
    
    class func getArrayFromPrefs(key: String) -> NSArray? {
        if let data = UserDefaults.standard.object(forKey: key) as? NSData {
            if let items = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? NSArray {
                return items
            }
        }
        return nil
    }
    
}

