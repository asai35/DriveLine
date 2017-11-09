//
//  TermsViewController.swift
//  DriveLine
//
//  Created by mac on 7/31/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {


    @IBOutlet var popUpView: UIView!
    @IBOutlet var fadeView: UIVisualEffectView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var closeButton: UIButton!

    var alertTitle : String!
    var alertSubTitle : String!

    var centerFrame : CGRect!
    var delegate : AlertControllerProtocol?

    var leftButtonTitle: String!
    var rightButtonTitle: String!
    var centerButtonTitle: String!

    @IBOutlet weak var textView: UITextView!
    var buttonStatus: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true

        self.modalPresentationStyle = .overCurrentContext

        self.popUpView.isHidden = true
        self.lblTitle.text = alertTitle

    }
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        centerFrame = self.popUpView.frame
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if alertTitle == "EULA" {
            if let rtfPath = Bundle.main.url(forResource: "eula", withExtension: "rtf") {
                do {
                    if #available(iOS 9.0, *) {
                        let attributedStringWithRtf = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType], documentAttributes: nil)
                        self.textView.attributedText = attributedStringWithRtf
                    } else {
                        // Fallback on earlier versions
                    }
                } catch {
                    print("Error loading text")
                }
            }
        }else{
            if let rtfPath = Bundle.main.url(forResource: "terms-conditions", withExtension: "rtf") {
                do {
                    if #available(iOS 9.0, *) {
                        let attributedStringWithRtf = try NSAttributedString(url: rtfPath, options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType], documentAttributes: nil)
                        self.textView.attributedText = attributedStringWithRtf
                    } else {
                        // Fallback on earlier versions
                    }
                } catch {
                    print("Error loading text")
                }
            }
        }

        presentPopUp()
    }

    func presentPopUp()  {

        popUpView.frame = CGRect(x: centerFrame.origin.x, y: view.frame.size.height, width: centerFrame.width, height: centerFrame.height)

        popUpView.isHidden = false

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.90, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {

            self.popUpView.frame = self.centerFrame

        }, completion: nil)

    }

    func dismissPopUp(_ dismissed:@escaping ()->())  {

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.90, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {

            self.popUpView.frame = CGRect(x: self.centerFrame.origin.x, y: self.view.frame.size.height, width: self.centerFrame.width, height: self.centerFrame.height)

        },completion:{ (completion) in

            self.dismiss(animated: false, completion: {

                dismissed()
            })
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func centerButtonPressed(_ sender: UIButton) {
        dismissPopUp {

            self.delegate?.closeAction!()
        }
    }
}
