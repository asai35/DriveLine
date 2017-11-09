//
//  NotificationHandler.swift
//  DriveLine
//
//  Created by mac on 8/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class NotificationHandler: NSObject {
    static var sharedInstance = NotificationHandler()

    var deviceToken : String!
    var notificationPayload :[String : AnyObject]!

    fileprivate override init() {
        super.init()
    }

    func handleNotificaTion(WithPayload payload:[String:AnyObject])  {

        // (1 = Chat Messages, 2 = New Matches, 3 = New Profiles, 4 = New Events, 5 = My Event Updates)

        print("Payload is ---->>>>> \(payload)")

        guard let notificationType = payload["type"] as? String else { return }

        switch notificationType {
        case "1":
            break
        default:
            break
        }
    }
    

}
