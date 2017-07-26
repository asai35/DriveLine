//
//  ExploreViewController.swift
//  DriveLine
//
//  Created by Abdul Wahib on 4/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftConstraints
import RoundCornerProgress

class ExploreViewController: UIViewController {
    
    let SEARCH_RESULTS_IDENTIFIER = "SEARCH_RESULTS_IDENTIFIER"

    // MARK: IBOutlets
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var radiusField: UITextField!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var eventsView: UIView!
    
    // MARK: Variables
    var selectedStyle = ""
    
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupEventsView()

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if radiusField.isFirstResponder {
            radiusField.resignFirstResponder()
        }
    }
    
    // MARK: Helper Methods
    func initViews() {
        goButton?.layer.cornerRadius = goButton.frame.size.width / 2
        eventsView.isHidden = true
        UIUtil.removeBackButtonTitleOfNavigationBar(navigationItem: self.navigationItem)
    }
    
    func setupEventsView() {
        callAllEventApi()
    }
    func callAllEventApi()  {
        let params = [
            URLConstant.Param.TAG: "getuserevent",
            "user_id": UserModel.shared.userid()
        ]
        UIUtil.showProcessing(message: "Loading...")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.USER_EVENT, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    let pageController = EventsViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
                    pageController.eventArray = json.object(forKey: "all_news") as? NSArray
                    let pc: UIPageControl = UIPageControl.appearance()
                    pc.pageIndicatorTintColor = UIColor.lightGray
                    pc.currentPageIndicatorTintColor = UIColor.black
                    pc.backgroundColor = UIColor.white
                    
                    self.addChildViewController(pageController)
                    pageController.view.frame = CGRect(x: 0, y: 0, width: self.eventsView.frame.size.width, height: self.eventsView.frame.size.height)
                    for vw in self.eventsView.subviews{
                        vw.removeFromSuperview()
                    }
                    self.eventsView.addSubview(pageController.view)
                    pageController.didMove(toParentViewController: self)
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)
                    
                }
                print(json)
            }
        }, failure: { (error) in
            
            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        })
        
    }
    
    // MARK: IBActions
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            searchView.isHidden = false
            eventsView.isHidden = true
        }else {
            searchView.isHidden = true
            eventsView.isHidden = false
        }
    }
    @IBAction func stylesClick(_ sender: UIButton) {
        self.view.endEditing(true)
        ActionSheetStringPicker.show(withTitle: "Select Drive Style", rows: Constant.Data.DRIVE_STYLES, initialSelection: 0, doneBlock: { (action, index, value) in
            if let string = value as? String {
                self.styleButton.setTitle(string, for: .normal)
                self.styleButton.setTitleColor(.black, for: .normal)
                self.selectedStyle = string
            }
        }, cancel: nil, origin: self.view)
    }
    
    @IBAction func goClick(_ sender: Any) {
        self.view.endEditing(true)
        if self.radiusField.text == "" {
            UIUtil.showToast(message: "Please enter the search radius")
            return
        }
        performSegue(withIdentifier: SEARCH_RESULTS_IDENTIFIER, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == SEARCH_RESULTS_IDENTIFIER {
                if let dvc = segue.destination as? SearchResultsViewController {
                    dvc.distance = self.radiusField.text
                    if self.selectedStyle == "" {
                        dvc.driveType = "none"
                    }else{
                        dvc.driveType = self.selectedStyle
                    }
                }
            }
        }
    }

}

class EventsViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var eventArray: NSArray?
//    let images = [#imageLiteral(resourceName: "drive"), #imageLiteral(resourceName: "mapview")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        let eventVC = EventFrameViewController()
        eventVC.event = self.eventArray?.firstObject as! [String : String]?
        eventVC.joinClickDelegate = {
            UIUtil.showProcessing(message: "Proccessing...")
            if eventVC.progressView.isHidden {
                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "joinevent", "creator_id": UserModel.shared.userid(), "event_id": eventVC.event?["id"] ?? ""], success: { (response) in
                    UIUtil.hideProcessing()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            eventVC.showProgressView(progress: 0)
                            self.callAllEventApi()
                        }else {
                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                        }
                        print(json)
                    }

                }, failure: { (error) in
                    UIUtil.hideProcessing()
                    UIUtil.showToast(message: error.localizedDescription)
                    print(error.localizedDescription)
                })
            }else {
                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "unjoinevent", "user_event_id": eventVC.event?["usereventid"] ?? ""], success: { (response) in
                    UIUtil.hideProcessing()
                    if let json = response as? NSDictionary {
                        if WebserviceUtil.isStatusOk(json: json) {
                            eventVC.hideProgressView()
                            self.callAllEventApi()
                        }else {
                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                        }
                        print(json)
                    }

                }, failure: { (error) in
                    UIUtil.hideProcessing()
                    UIUtil.showToast(message: error.localizedDescription)
                    print(error.localizedDescription)
                })
            }
        }
        let viewControllers = [eventVC]
        self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
    }
    func callAllEventApi()  {
        let params = [
            URLConstant.Param.TAG: "getuserevent",
            "user_id": UserModel.shared.userid()
        ]
        UIUtil.showProcessing(message: "Loading...")
        WebserviceUtil.callGet(httpRequest: URLConstant.API.USER_EVENT, params: params, success: { (response) in
            UIUtil.hideProcessing()
            if let json = response as? NSDictionary {
                if WebserviceUtil.isStatusOk(json: json) {
                    self.eventArray = json.object(forKey: "all_news") as? NSArray
                    self.didMove(toParentViewController: self)
                }else {
                    UIUtil.showToast(message: json.object(forKey: "response") as! String)

                }
                print(json)
            }
        }, failure: { (error) in

            UIUtil.hideProcessing()
            UIUtil.showToast(message: error.localizedDescription)
            print(error.localizedDescription)
        })

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = view.subviews.filter({ $0 is UIScrollView }).first,
            let pc = view.subviews.filter({ $0 is UIPageControl }).first {
            scrollView.frame = view.bounds
            view.bringSubview(toFront:pc)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentEvent = (viewController as! EventFrameViewController).event {
            var index = 0
            for i in 0..<eventArray!.count {
                if (eventArray?.object(at: i) as! [String: String])["id"] == currentEvent["id"] {
                    index = i
                }
            }
                if index < (eventArray?.count)! - 1 {
                    let eventVC = EventFrameViewController()
                    eventVC.event = eventArray?.object(at: index + 1) as! [String : String]?
                    eventVC.joinClickDelegate = {
                            UIUtil.showProcessing(message: "Proccessing...")
                            if eventVC.progressView.isHidden {
                                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "joinevent", "creator_id": UserModel.shared.userid(), "event_id": eventVC.event?["id"] ?? ""], success: { (response) in
                                    UIUtil.hideProcessing()
                                    if let json = response as? NSDictionary {
                                        if WebserviceUtil.isStatusOk(json: json) {
                                            eventVC.showProgressView(progress: 0)
                                            self.callAllEventApi()
                                        }else {
                                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                                        }
                                        print(json)
                                    }

                                }, failure: { (error) in
                                    UIUtil.hideProcessing()
                                    UIUtil.showToast(message: error.localizedDescription)
                                    print(error.localizedDescription)
                                })
                            }else {
                                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "unjoinevent", "user_event_id": eventVC.event?["usereventid"] ?? ""], success: { (response) in
                                    UIUtil.hideProcessing()
                                    if let json = response as? NSDictionary {
                                        if WebserviceUtil.isStatusOk(json: json) {
                                            eventVC.hideProgressView()
                                            self.callAllEventApi()
                                        }else {
                                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                                        }
                                        print(json)
                                    }
                                    
                                }, failure: { (error) in
                                    UIUtil.hideProcessing()
                                    UIUtil.showToast(message: error.localizedDescription)
                                    print(error.localizedDescription)
                                })
                            }
                    }
                    return eventVC
                }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentEvent = (viewController as! EventFrameViewController).event {
            var index = 0
            for i in 0..<eventArray!.count {
                if (eventArray?.object(at: i) as! [String: String])["id"] == currentEvent["id"] {
                    index = i
                }
            }
                if index > 0 {
                    let eventVC = EventFrameViewController()
                    eventVC.event = eventArray?.object(at: index - 1) as! [String : String]?
                    eventVC.joinClickDelegate = {
                            UIUtil.showProcessing(message: "Proccessing...")
                            if eventVC.progressView.isHidden {
                                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "joinevent", "creator_id": UserModel.shared.userid(), "event_id": eventVC.event?["id"] ?? ""], success: { (response) in
                                    UIUtil.hideProcessing()
                                    if let json = response as? NSDictionary {
                                        if WebserviceUtil.isStatusOk(json: json) {
                                            eventVC.showProgressView(progress: 0)
                                            self.callAllEventApi()
                                        }else {
                                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                                        }
                                        print(json)
                                    }

                                }, failure: { (error) in
                                    UIUtil.hideProcessing()
                                    UIUtil.showToast(message: error.localizedDescription)
                                    print(error.localizedDescription)
                                })
                            }else {
                                WebserviceUtil.callPost(httpRequest: URLConstant.API.JOIN_EVENT, params: ["tag": "unjoinevent", "user_event_id": eventVC.event?["usereventid"] ?? ""], success: { (response) in
                                    UIUtil.hideProcessing()
                                    if let json = response as? NSDictionary {
                                        if WebserviceUtil.isStatusOk(json: json) {
                                            eventVC.hideProgressView()
                                            self.callAllEventApi()
                                        }else {
                                            UIUtil.showToast(message: json.object(forKey: "response") as! String)
                                        }
                                        print(json)
                                    }

                                }, failure: { (error) in
                                    UIUtil.hideProcessing()
                                    UIUtil.showToast(message: error.localizedDescription)
                                    print(error.localizedDescription)
                                })
                            }
                    }
                    return eventVC
                }
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return eventArray!.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func joinClick() {
    
    }

}

class EventFrameViewController: UIViewController, DisclaimerViewDelegate {
    
    var image: String? {
        didSet {
            if (image != nil && image != ""){
                imageView.setImageWith(URL(string: image!)!, placeholderImage: UIImage(named:"drive"))
            }else{
                imageView.image = #imageLiteral(resourceName: "drive")
            }
        }
    }
    var disclaimer = DisclaimerView.initView()

    var event: [String: String]? {
        didSet {
            self.image = (event?["image"])! as String
        }
    }
    
    let leadingMargin: CGFloat = 32.0
    let trailingMargin: CGFloat = 32.0
    
    var eventTitle: String?
    var detail: String?
    var points: String?
    
    var joinClickDelegate: (() -> Void)?
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 4
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8.0

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(colorLiteralRed: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let detailButton: UIButton = {
        let button = UIButton()
        button.setTitle("View Event Detail", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let imageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var progressView: RoundCornerProgressView!
    var progressViewText: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backgroundCard = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        eventTitle = event?["title"]
        detail = ""
        detail?.append((event?["text"])!+"\n") //"Before May 31st Map and Save 100 Miles of “Loose Service” Style Drives"
        if event?["area"] != "" {
            detail?.append("Area:  "+(event?["text"])!+"\n")
        }
        if event?["drive_length"] != "" {
            detail?.append("Drive Length: "+(event?["drive_length"])!+"(miles)\n")
        }
        if event?["drive_style"] != "" {
            let arraystyle = (event?["drive_style"]!)?.components(separatedBy: ";")
            detail?.append("Drive Style: \n")
            for si in arraystyle! {
                let i = Int(si)
                if i == nil {
                    return
                }
                if i == 0 {
                    detail?.append("\t\t-All\n")
                }else{
                    detail?.append("\t\t-"+Constant.Data.DRIVE_STYLES[i! - 1]+"\n")
                }
            }
//            detail?.append("Drive Style: "+(event?["drive_style"])!+"\n")
        }
        if event?["start_date"] != "" {
            detail?.append("Start Date: "+(event?["start_date"])!+"\n")
        }
        if event?["end_date"] != "" {
            detail?.append("End Date: "+(event?["end_date"])!+"\n")
        }
        if event?["timeline"] != "" {
            detail?.append("Timeline: "+(event?["timeline"])!+"(days)\n")
        }
        if event?["video_count"] != "0" {
            detail?.append("Video Count: "+(event?["video_count"])!+"\n")
        }
        if event?["drive_count"] != "0" {
            detail?.append("Drive_count: "+(event?["drive_count"])!+"\n")
        }
//        points = event?["points"] //"25 bonus points"
        points = (event?["points"])!+" bonus points"
        
        titleLabel.text = eventTitle
        detailLabel.text = detail
        pointsLabel.text = points
        
        backgroundCard.backgroundColor = .white
        backgroundCard.translatesAutoresizingMaskIntoConstraints = false
        UIUtil.drawShadow(view: backgroundCard, size: CGSize(width: 0, height: 2), color: UIColor(red: 0,green: 0,blue: 0,alpha: 0.5), opacity: 0.7, shadowRadius: 4.0)
        
        
        // Adding Progress View
        self.progressView = RoundCornerProgressView(frame: CGRect(x: 20, y: 20, width: 200, height: 15))
        self.progressView.trackTintColor = UIColor.gray
        self.progressView.labelColor = .clear
        self.progressView.progressTintColor = UIColor(colorLiteralRed: 126/255, green: 211/255, blue: 33/255, alpha: 1)
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        
        joinButton.addTarget(self, action: #selector(EventFrameViewController.joinClick), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(EventFrameViewController.detailClick), for: .touchUpInside)

        progressView.isHidden = true
        progressViewText.isHidden = true
        
        if event?["isjoined"] == "0" {
            progressView.isHidden = true
            progressViewText.isHidden = true
            joinButton.setTitle("Join", for: .normal)
            joinButton.backgroundColor = UIColor(colorLiteralRed: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        }else if event?["isjoined"] == "1" {
            progressView.isHidden = false
            progressViewText.isHidden = false
            progressView.progress = CGFloat(Float(event!["progress"]!)!)
            progressViewText.text = "\(event!["progress"]!)% Complete"
            joinButton.setTitle("Un-Join", for: .normal)
            joinButton.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 166/255, blue: 35/255, alpha: 1)
        }
        
        
        
        view.addSubview(backgroundCard)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(detailLabel)
        view.addSubview(pointsLabel)
        view.addSubview(joinButton)
        view.addSubview(detailButton)
        view.addSubview(self.progressView)
        view.addSubview(self.progressViewText)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        
        // Set Background Card Constraints
        self.view.addConstraint(toItem: backgroundCard, attribute: .top, constant: 8)
        self.view.addConstraint(toItem: backgroundCard, attribute: .left, constant: -16)
        self.view.addConstraint(toItem: backgroundCard, attribute: .right, constant: 16)
        self.view.addConstraint(toItem: backgroundCard, attribute: .bottom, constant: 40)
        
        
        // Set Title Constraints
        self.view.addConstraint(toItem: titleLabel, attribute: .top, constant: 8)
        self.view.addConstraint(toItem: titleLabel, attribute: .leading)
        self.view.addConstraint(toItem: titleLabel, attribute: .trailing)
        
        // Set ImageView Contraints
        self.view.addConstraint(betweenItems: titleLabel, toItem: imageView, axis: .vertical, constant: 6)
        self.view.addConstraint(toItem: imageView, attribute: .leading, constant: leadingMargin)
        self.view.addConstraint(toItem: imageView, attribute: .trailing, constant: trailingMargin)
        imageView.addConstraint(toSelf: .height, constant: self.view.frame.size.height * 0.25)
        
        // Set Detail Label Constraints
        self.view.addConstraint(betweenItems: imageView, toItem: detailLabel, axis: .vertical, constant: 6)
        self.view.addConstraint(toItem: detailLabel, attribute: .leading, constant: leadingMargin)
        self.view.addConstraint(toItem: detailLabel, attribute: .trailing, constant: trailingMargin)
        
        // Set Points Label Constraints
        self.view.addConstraint(betweenItems: detailLabel, toItem: pointsLabel, axis: .vertical, constant: 6)
        self.view.addConstraint(toItem: pointsLabel, attribute: .leading, constant: leadingMargin)
        self.view.addConstraint(toItem: pointsLabel, attribute: .trailing, constant: trailingMargin)
        
        // Add Constraints to ProgressView
        self.view.addConstraint(betweenItems: pointsLabel, toItem: progressView, axis: .vertical, constant: 6)
        self.view.addConstraint(toItem: progressView, attribute: .leading, constant: leadingMargin)
        self.view.addConstraint(toItem: progressView, attribute: .trailing, constant: trailingMargin)
        progressView.addConstraint(toSelf: .height, constant: 30)
        
        // Add Constraints to ProgressView Title
        self.view.addConstraint(withItems: progressView, andItem: progressViewText, attribute: .centerX, constant: 0)
        self.view.addConstraint(withItems: progressView, andItem: progressViewText, attribute: .centerY, constant: 0)
        
        // Set Join Button Constraints
        self.view.addConstraint(betweenItems: progressView, toItem: joinButton, axis: .vertical, constant: 8)
        self.view.addConstraint(toItem: joinButton, attribute: .centerX)
        joinButton.addConstraint(toSelf: .height, constant: 30)
        joinButton.addConstraint(toSelf: .width, constant: 150)
        joinButton.layer.cornerRadius = 4

        // Set detail Button Constraints
        self.view.addConstraint(betweenItems: joinButton, toItem: detailButton, axis: .vertical, constant: 8)
        self.view.addConstraint(toItem: detailButton, attribute: .centerX)
        detailButton.addConstraint(toSelf: .height, constant: 30)
        detailButton.addConstraint(toSelf: .width, constant: 150)

    }
    
    func showProgressView(progress: Int) {
        // Init ProgressView
        
        self.progressView.isHidden = false
        self.progressViewText.isHidden = false
        
        self.progressView.progress = CGFloat(progress) / 100
        self.progressViewText.text = "\(progress)% Complete"
        
        joinButton.setTitle("Un-Join", for: .normal)
        joinButton.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 166/255, blue: 35/255, alpha: 1)
        
        
    }
    
    func hideProgressView() {
        self.progressView.isHidden = true
        self.progressViewText.isHidden = true
        
        joinButton.setTitle("Join", for: .normal)
        joinButton.backgroundColor = UIColor(colorLiteralRed: 74/255, green: 144/255, blue: 226/255, alpha: 1)
        
    }

    func joinClick() {
        joinClickDelegate?()
    }

    func detailClick() {
        disclaimer = DisclaimerView.initWith(title: eventTitle!, content: detail!, image: (event?["image"]!)!, delegate: self)
//        disclaimer.imgView.setImageWith(URL(string: image!)!, placeholderImage: UIImage(named:"drive"))
        self.view.window?.addSubview(disclaimer)
    }

    func acceptDisclaimer(index: Int) {
        print("acceptDisclaimer index: \(index)")

        if index == -1 {
            disclaimer.removeFromSuperview()
        }

    }

    func cancelDisclaimer(index: Int) {
        print("cancelDisclaimer index: \(index)")
        disclaimer.removeFromSuperview()
    }

    
}
