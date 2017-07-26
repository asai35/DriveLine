//
//  RegisterViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class RegisterViewController: UIViewController, UITextFieldDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var nameField: LoginTextField!
    @IBOutlet weak var emailField: LoginTextField!
    @IBOutlet weak var passwordField: LoginTextField!
    @IBOutlet weak var confirmPasswordField: LoginTextField!
    let REG_HOME = "REG_HOME"

    
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
        
        self.nameField.attributedPlaceholder = NSAttributedString(string : "UserName",
                                                                  attributes : placeholderAttributes)
        
        self.emailField.attributedPlaceholder = NSAttributedString(string : "Email",
                                                                   attributes : placeholderAttributes)
        self.passwordField.attributedPlaceholder = NSAttributedString(string : "Password",
                                                                  attributes : placeholderAttributes)
        
        self.confirmPasswordField.attributedPlaceholder = NSAttributedString(string : "Confirm Password",
                                                                   attributes : placeholderAttributes)
    }
    
    func isValidData() -> (status: Bool,message: String) {
        if nameField.text!.isEmpty {
            return (false,"Name is requried")
        }else if emailField.text!.isEmpty {
            return (false,"Email is required")
        }else if !ValidationUtil.isValidEmail(testStr: emailField.text!) {
            return (false,"Email is invalid")
        }else if passwordField.text!.isEmpty {
            return (false, "Password is required")
        }else if confirmPasswordField.text! != passwordField.text! {
            return (false, "Password doesn't match")
        }else {
            return (true,"")
        }
    }
    
    // MARK: UITextfieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: API Calls
    func callRegisterAPI() {
        let params = [
            URLConstant.Param.TAG: "register",
            URLConstant.Param.NAME: nameField.text!,
            URLConstant.Param.EMAIL: emailField.text!,
            URLConstant.Param.PASSWORD: passwordField.text!
        ]
        UIUtil.showProcessing(message: "Please wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.REGISTER, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.performSegue(withIdentifier: self.REG_HOME, sender: self)
                }else {
                    UIUtil.showToast(message: (json.object(forKey: "response") as! String))
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
        }
    }
    
    // MARK: IBActions
    @IBAction func registerClick(_ sender: Any) {
        let result = isValidData()
        if !result.status {
            UIUtil.showToast(message: result.message)
            return
        }
        
        callRegisterAPI()
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
