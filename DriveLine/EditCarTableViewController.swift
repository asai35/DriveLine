//
//  EditCarTableViewController.swift
//  DriveLine
//
//  Created by mac on 5/12/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class EditCarTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var makeField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    var carImage: UIImage?
    let imagePicker = UIImagePickerController()
    var model = UserModel.shared
    var myCar: NSDictionary = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()

    }
    // MARK: Helper Methods
    func initViews() {
        carImageView.layer.cornerRadius = carImageView.frame.size.width / 2
        carImageView.contentMode = .scaleAspectFit
        carImageView.clipsToBounds = true
        carImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditCarTableViewController.imageClick)))
        let url = URL(string: myCar["car"] as! String)
        if url != nil {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    if data != nil {
                        self.carImage = UIImage(data:data!)
                        self.carImageView.image = self.carImage
                    }else{
                        self.carImage = UIImage(named: "default.png")
                        self.carImageView.image = self.carImage
                    }
                }
            }
        }
        yearField.text = myCar["year"] as? String
        makeField.text = myCar["make"] as? String
        modelField.text = myCar["model"] as? String
        
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
        carImageView.contentMode = .scaleAspectFit
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
    
    @IBAction func updateClick(_ sender: Any) {
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
        let params = [URLConstant.Param.TAG: "updateride",
                      URLConstant.Param.RIDEID: myCar["ride_id"] as! String,
                      URLConstant.Param.YEAR: yearField.text!,
                      URLConstant.Param.MODEL: modelField.text!,
                      URLConstant.Param.MAKE: makeField.text!]
        UIUtil.showProcessing(message: "Pelase wait")
        WebserviceUtil.callPostMultipartData(httpRequest: URLConstant.API.EDIT_RIDE, params: params , image: self.carImage, imageParam: "image", success: { (response) in
            
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    UIUtil.showToast(message: json["response"] as! String)
                    let _ = self.navigationController?.popViewController(animated: true)
                    
                }else {
                    UIUtil.showToast(message: json["response"] as! String)
                }
                print(json)
            }
        }) { (error) in
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    // MARK: IBActions
    @IBAction func deleteClick(_ sender: Any) {
        let uid = model.userid()
        let params = [URLConstant.Param.TAG: "deleteride",
                      URLConstant.Param.CREATORID: uid,
                      URLConstant.Param.RIDEID: myCar["ride_id"] as! String]
        UIUtil.showProcessing(message: "Pelase wait")
        WebserviceUtil.callPost(httpRequest: URLConstant.API.DELETE_RIDE, params: params, success: { (response) in
            
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EditCarTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            carImage = pickedImage
            selectedImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}

