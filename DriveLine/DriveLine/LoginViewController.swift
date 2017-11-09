//
//  LoginViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let HOME_IDENTIFIER = "HOME_IDENTIFIER"
    var recoverEmail : String = ""
    var confirmCode: String = ""
    var recoverPassword: String = ""
    // MARK: IBOutlets
    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    
    var model = UserModel.shared
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        IQKeyboardManager.sharedManager().enable = true
        let placeholderAttributes = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName : UIFont(name:"Avenir", size: 14)!]
        
        self.emailField.attributedPlaceholder = NSAttributedString(string : "Email",
                                                                    attributes : placeholderAttributes)
        
        self.passwordField.attributedPlaceholder = NSAttributedString(string : "Password",
                                                                       attributes : placeholderAttributes)
        emailField.text = model.useremail()
        passwordField.text = model.userpassword()
    }
    
    func isValidData() -> (status: Bool,message: String) {
        if emailField.text!.isEmpty {
            return (false,"Email is required")
        }else if !ValidationUtil.isValidEmail(testStr: emailField.text!) {
            return (false,"Email is invalid")
        }else if passwordField.text!.isEmpty {
            return (false, "Password is required")
        }else {
            return (true,"")
        }
    }
    
    // MARK: API Calls
    func callLoginAPI() {
        var params = [
            URLConstant.Param.TAG: "login",
            URLConstant.Param.EMAIL: emailField.text!,
            URLConstant.Param.PASSWORD: passwordField.text!
        ]
        if NotificationHandler.sharedInstance.deviceToken != nil {
            params["device_token"] = NotificationHandler.sharedInstance.deviceToken
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
                    let user: UserModel = UserModel.init(object: ["email" : json["email"] as! String, "password": self.passwordField.text! as String])
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
                    self.performSegue(withIdentifier: self.HOME_IDENTIFIER, sender: self)
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            self.performSegue(withIdentifier: self.HOME_IDENTIFIER, sender: self)

            print(error.localizedDescription)
        }
    }
    
    // MARK: UITextfieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: IBActions
    @IBAction func loginClick(_ sender: Any) {
        let result = isValidData()
        if !result.status {
            UIUtil.showToast(message: result.message)
            return
        }
        // Call Login API here
        callLoginAPI()
    }
    
    @IBAction func registerClick(_ sender: Any) {
    }
    
    @IBAction func forgotPasswordClick(_ sender: Any) {
        let alert = UIAlertController(title: "Forget Password", message: "Enter your Email", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Email"
            field.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action) in
            self.recoverEmail = (alert.textFields?[0].text!)!
            self.callForgotPasswordAPI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func callForgotPasswordAPI() {
        let params = [
            URLConstant.Param.TAG: "forgot",
            URLConstant.Param.EMAIL: self.recoverEmail
        ]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.FORGOT, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.confirmCode = String(json.object(forKey: "code") as! Int)
                    self.InputConfirmCode()
                }else {
                    UIUtil.showMessage(title: "Failed", message: json.object(forKey: "message") as! String, controller: self, okHandler: nil)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showMessage(title: "Failed", message: error.localizedDescription, controller: self, okHandler: nil)

            print(error.localizedDescription)
        }
    }
    func InputConfirmCode() {
        let alert = UIAlertController(title: "Forget Password", message: "We had sent you a code to reset the password to your mail. Please check in inbox or spam folder.\nEnter your Confirm code", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Confirm code"
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            if self.confirmCode == (alert.textFields?[0].text!)!{
                self.InputNewPassword()
            }else{
                UIUtil.showMessage(title: "Failed", message: "Your code does not match, Please enter valid code again", controller: self, okHandler: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func InputNewPassword() {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your new password", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "New password"
            field.isSecureTextEntry = true
        }
        alert.addTextField { (field) in
            field.placeholder = "Confirm password"
            field.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Recover", style: .default, handler: { (action) in
            if (alert.textFields?[0].text!)! != (alert.textFields?[1].text!)!{
                UIUtil.showMessage(title: "Warning", message: "Confirm password doesn't match, Please try again later", controller: self, okHandler: nil)
                return
            }
            if (alert.textFields?[0].text!)! != ""{
                self.recoverPassword = (alert.textFields?[0].text!)!
                self.callResetPasswordAPI()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func callResetPasswordAPI() {
        let params = [
            URLConstant.Param.TAG: "reset",
            URLConstant.Param.EMAIL: self.recoverEmail,
            URLConstant.Param.PASSWORD: self.recoverPassword
        ]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.RESET, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    UIUtil.showMessage(title: "Success", message: "Your password was changed", controller: self, okHandler: nil)
                }else {
                    UIUtil.showMessage(title: "Failed", message: json.object(forKey: "message") as! String, controller: self, okHandler: nil)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showMessage(title: "Failed", message: error.localizedDescription, controller: self, okHandler: nil)
            
            print(error.localizedDescription)
        }
    }
}


