//
//  NotificationsTableViewController.swift
//  DriveLine
//
//  Created by mac on 8/22/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {
    var model = UserModel.shared

    var notifications = NSMutableArray.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getNotifications()
    }

    @IBAction func ActionClear(_ sender: UIBarButtonItem) {
        self.removeAllNotifications()
    }
    func getNotifications() {

        let params = ["user_id": model.userid(), "tag": "get"]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.NOTIFICATION, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.notifications = ((json.object(forKey: "notifications") as! NSArray).mutableCopy() as! NSMutableArray)
                    self.model.userbadge(0)

                    (self.tabBarController?.tabBar.items?[3])?.badgeValue = ""
                    if #available(iOS 10.0, *) {
                        (self.tabBarController?.tabBar.items?[3])?.badgeColor = .clear
                    } else {
                        // Fallback on earlier versions
                    }
                        

                    self.tableView.reloadData()
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }

    func removeAllNotifications() {
        let params = ["user_id": model.userid(), "tag": "remove"]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.NOTIFICATION, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.notifications = NSMutableArray.init()
                    self.tableView.reloadData()
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfSections: Int = 0
        if notifications.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text          = "No Data Found"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell

        let noti = notifications.object(at: indexPath.row) as! NSDictionary
        cell.message.text = noti.object(forKey: "message") as? String
        cell.timeLabel.text = (noti.object(forKey: "created_date") as? String)?.FeedDate()

        if (noti.object(forKey: "type") as! String) == "1" || (noti.object(forKey: "type") as! String) == "4" {
            cell.commentImageView.image = #imageLiteral(resourceName: "ic_driveline")
        }else{
            if (noti.object(forKey: "photo_url") != nil) {
                if (URL(string: noti.object(forKey: "photo_url") as! String) != nil) {
                    cell.commentImageView.setImageWith(URL(string: noti.object(forKey: "photo_url") as! String)!, placeholderImage: #imageLiteral(resourceName: "person-avatar"))
                }else{
                    cell.commentImageView.image = #imageLiteral(resourceName: "person-avatar")
                }
            }
        }

        if (noti.object(forKey: "isread") as! String) == "0" {
            cell.backgroundColor = .lightGray
        }else{
            cell.backgroundColor = .clear
        }
        cell.selectionStyle = .none

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
