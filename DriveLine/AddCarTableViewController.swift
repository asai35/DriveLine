//
//  AddCarTableViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/21/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class AddCarTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var makeField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    var carImage: UIImage?
    // MARK: Variables
    let imagePicker = UIImagePickerController()
    var model = UserModel.shared
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        userPoints.text = "\(model.userpoint()) points"

        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        
        carImageView.layer.cornerRadius = carImageView.frame.size.width / 2
        carImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddCarTableViewController.imageClick)))
        userName.text = model.username()
    }
    
    func imageClick() {
        
            let sheet = UIAlertController(title: "Select Image", message: "Select an image source", preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Capture from Camera", style: .default, handler: { (action) in
                self.captureImageCamera()
            }))
            sheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                self.selectImageFromGallery()
            }))
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        
    }
    
    func selectImageFromGallery() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func selectedImage(image: UIImage) {
        carImageView.image = image
        carImageView.contentMode = .scaleAspectFill
        carImageView.clipsToBounds = true
    }
    
    func captureImageCamera() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: IBActions
    @IBAction func saveClick(_ sender: Any) {
        if yearField.text == "" {
            UIUtil.showToast(message: "Please type the car year")
            return
        }
        if makeField.text == "" {
            UIUtil.showToast(message: "Please type the car make")
            return
        }
        if modelField.text == "" {
            UIUtil.showToast(message: "Please type the car model")
            return
        }
        if carImage == nil {
            carImage = UIImage.init()
        }
        let uid = model.userid()
        let params = [URLConstant.Param.TAG: "newride",
                      URLConstant.Param.CREATORID: uid,
                      URLConstant.Param.YEAR: yearField.text!,
                      URLConstant.Param.MODEL: modelField.text!,
                      URLConstant.Param.MAKE: makeField.text!]
        UIUtil.showProcessing(message: "Pelase wait")
        WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.ADD_NEWRIDE, params: params , image: carImage, imageParam: "image", success: { (response) in
            
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    UIUtil.showToast(message: json["response"] as! String)
                    let count = Int(json["mycars"] as! Int64)
                    self.model.mycars(String(count))
                    let _ = self.navigationController?.popViewController(animated: true)

                }else {
                    UIUtil.showToast(message: json["response"] as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            print(error.localizedDescription)
        }
    }
    
}

extension AddCarTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            carImage = pickedImage
            selectedImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
