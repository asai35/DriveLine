//
//  VideoViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/19/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var webView: UIWebView!
    
    
    // MARK: Variables
//    var link = "https://www.youtube.com/embed/Pr9Sb_tNiCc"
    var link : String = ""
    
    // MARK: VC Lifecycle
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .black
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Helper Methods
    func initViews() {
        if link != ""{
            let request = URLRequest(url: URL(string:link )!)
            webView.loadRequest(request)

        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: IBActions
    
    
}
