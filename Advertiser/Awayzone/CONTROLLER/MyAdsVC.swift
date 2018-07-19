//
//  MyAdsVC.swift
//  Awayzone
//
//  Created by Pushpinder Kaur on 29/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class MyAdsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -
    @IBOutlet weak var adsTV: UITableView!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    var myAdsArr  = NSMutableArray()
    var iMGURL  = String()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getAllUserAds()
    }
    
    func getAllUserAds() -> Void {
        
        let paramDict = ["user_id"     :utilClass.getUserID()] as NSDictionary
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KGetAds, paramDictionary: paramDict) { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    if let imgUrl   = responseDict["image_url"] as? String{
                        self.iMGURL  = imgUrl
                    }
                    
                    if let adsArr   = responseDict["ads"] as? NSArray {
                        self.myAdsArr    = adsArr as! NSMutableArray
                    }
                    self.adsTV.reloadData()
                }
            }
        }
    }
    
    //MARK: - UIButtonAction
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onOffSwitch(_ sender: UISwitch) {
        
        var status  = "on"
        if !sender.isOn {
            status  = "off"
        }
        let dict    = myAdsArr[sender.tag] as! NSDictionary
        let paramDict = ["user_id"     :utilClass.getUserID(),
                         "id"  : "\(dict["ad_id"]!)",
            "on_off" : status] as NSDictionary
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KOnOffAds, paramDictionary: paramDict) { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("1"){
                        
                    }
                    else {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                }
            }
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myAdsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "AdsTVC", for: indexPath) as! AdsTVC
        cell.selectionStyle = .none
        let dict    = myAdsArr[indexPath.row] as! NSDictionary
        
        cell.adIMG.sd_setImage(with: URL(string: "\(iMGURL)\(dict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.startDateLB.text   = "Start Date: \(dict["start_date"]!)"
        cell.endDateLB.text     = "End Date: \(dict["end_date"]!)"
        cell.impressionsLB.text = "\(dict["impression"]!)"
        cell.clicksLB.text      = "\(dict["clicks"]!)"
        
        cell.onOffSwitch.isHidden   = true
        cell.pendingLB.isHidden     = true
        
        if dict["status"] as! Bool == false {
            cell.pendingLB.isHidden     = false
            cell.pendingLB.text     = "Pending"
        }
        else  {
            cell.onOffSwitch.isHidden   = false
            if dict["on_off"] as! Bool == true {
                cell.onOffSwitch.isOn   = true
            }
            else  {
                cell.onOffSwitch.isOn   = false
            }
        }
        
        cell.onOffSwitch.tag    = indexPath.row
        /*
         
         {
         "ad_id" = 101;
         clicks = 0;
         description = "hello my I am not going to ";
         "end_date" = "29.05.2018";
         "end_time" = "6:10:15 AM";
         image = "1527585994test.png";
         impression = 0;
         "on_off" = 0;
         "start_date" = "29.05.2018";
         "start_time" = "2:12:15 AM";
         status = 0;
         title = "hello ad ";
         }
         */
        
        //cell.startDateLB
        //cell.adIMG
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 270
    }
    
    //MARK: -
    
    @IBAction func actionAddAds(_ sender: Any) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "CreateAdVC") as! CreateAdVC
        self.navigationController?.pushViewController(view, animated: true)
    }
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
