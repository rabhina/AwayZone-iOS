//
//  HomeVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet var sortBTN: UIButton!
    
    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var homeCV: UICollectionView!
    
    @IBOutlet weak var btnStar1: UIButton!
    @IBOutlet weak var btnStar2: UIButton!
    @IBOutlet weak var btnStar3: UIButton!
    @IBOutlet weak var btnStar4: UIButton!
    @IBOutlet weak var btnStar5: UIButton!
    
    @IBOutlet var impLB: UILabel!
    @IBOutlet var reviewLB: UILabel!
    
    @IBOutlet var shareLB: UILabel!
    @IBOutlet var beenHereLB: UILabel!
    @IBOutlet var clickLB: UILabel!
    @IBOutlet var commentLB: UILabel!
    
    @IBOutlet var likesLB: UILabel!
    @IBOutlet var bookmarkLB: UILabel!
    @IBOutlet var storiesLB: UILabel!
    @IBOutlet var ratingLB: UILabel!
    @IBOutlet var homeSV: UIScrollView!
    @IBOutlet var noDataLB: UILabel!
    
    //MARK: -
    
    var myAdsArr        = NSMutableArray()
    var homeDataArr     = NSMutableArray()
    var ratingStr       = 0
    var iMGURL          = String()
    
    var currentItem     = 0
    var sortBy          = "day"
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeSV.isHidden    = true
        noDataLB.isHidden   = true
        
        sortBTN.setTitle("LAST 7 DAYS", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDashboardData()
        let defaults    = UserDefaults.standard

        if "\(defaults.value(forKey: "image_url") as? String ?? "")\(defaults.value(forKey: "image") as? String ?? "")" != "" {
            userIMG.sd_setImage(with: URL(string: "\(defaults.value(forKey: "image_url") as? String ?? "")\(defaults.value(forKey: "image")  as? String ?? "")")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
        }
    }
    
    func getDashboardData() -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID(),
                         "type" : sortBy,
                         "record_type" : "analytic"] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KDashboard, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    if let statusstr = responseDict["status"] as? String {
                        if statusstr == "0" {
                            self.homeSV.isHidden    = true
                            self.noDataLB.isHidden   = false
                        }
                        else {
                            self.homeSV.isHidden    = false
                            self.noDataLB.isHidden   = true
                            
                        }
                    }
                    else {
                        
                        self.homeSV.isHidden    = false
                        self.noDataLB.isHidden   = true
                        
                        if let imgUrl   = responseDict["image_url"] as? String{
                            self.iMGURL  = imgUrl
                        }
                        
                        let dict = responseDict as NSDictionary
                        
                        if let recommen = dict["analytics"] as? NSArray {
                            self.homeDataArr  = NSMutableArray()
                            self.homeDataArr.addObjects(from: recommen as! [Any])
                        }
                        
                        if let ratingS  = dict["rating_sum"] as? Int {
                            self.ratingStr   = ratingS
                        }
                        
                        self.updateView()
                    }
                }
            }
        })
    }
    
    func updateView() {
        
        ratingLB.text   = "(\(Float(ratingStr)))"
        
        btnStar1.isSelected = false
        btnStar2.isSelected = false
        btnStar3.isSelected = false
        btnStar4.isSelected = false
        btnStar5.isSelected = false
        
        switch ratingStr {
        case 1:
            btnStar1.isSelected = true
            break
        case 2:
            btnStar1.isSelected = true
            btnStar2.isSelected = true
            break
        case 3:
            btnStar1.isSelected = true
            btnStar2.isSelected = true
            btnStar3.isSelected = true
        case 4:
            btnStar1.isSelected = true
            btnStar2.isSelected = true
            btnStar3.isSelected = true
            btnStar4.isSelected = true
        case 5:
            btnStar1.isSelected = true
            btnStar2.isSelected = true
            btnStar3.isSelected = true
            btnStar4.isSelected = true
            btnStar5.isSelected = true
        default:
            btnStar1.isSelected = false
            btnStar2.isSelected = false
            btnStar3.isSelected = false
            btnStar4.isSelected = false
            btnStar5.isSelected = false
        }
        
        if homeDataArr.count > 0 {
            if let responseDict = homeDataArr[0] as? NSDictionary {
                
                storiesLB.text      = "\(responseDict["get_story"] as? Int ?? 0)"
                beenHereLB.text     = "\(responseDict["get_been_here"] as? Int ?? 0)"
                bookmarkLB.text     = "\(responseDict["get_bookmarks"] as? Int ?? 0)"
                clickLB.text        = "\(responseDict["get_click"] as? Int ?? 0)"
                commentLB.text      = "\(responseDict["get_comment"] as? Int ?? 0)"
                impLB.text          = "\(responseDict["get_impression"] as? Int ?? 0)"
                likesLB.text        = "\(responseDict["get_like"] as? Int ?? 0)"
                reviewLB.text       = "\(responseDict["get_review"] as? Int ?? 0)"
                shareLB.text        = "\(responseDict["get_share"] as? Int ?? 0)"
            }
        }
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
                    self.homeCV.reloadData()
                }
            }
        }
    }
    
    
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if myAdsArr.count > 0 {
            return myAdsArr.count }
        else{
            return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCVC", for: indexPath as IndexPath) as! CategoriesCVC
        
        let dict    = myAdsArr[indexPath.row] as! NSDictionary
        
        cell.categoryIMG.sd_setImage(with: URL(string: "\(iMGURL)\(dict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.impressionsLB.text = "\(dict["impression"]!)"
        cell.clicksLB.text      = "\(dict["clicks"]!)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.size.width) , height: 290)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    //MARK: - CellButtonActions
    
    @IBAction func actionNextBtn(_ sender: Any) {
        
        if currentItem+1 < myAdsArr.count {
            
            currentItem     = currentItem+1
            let nextItem: IndexPath = IndexPath(item: currentItem, section: 0)
            if nextItem.row < myAdsArr.count {
                homeCV.scrollToItem(at: nextItem, at: .left, animated: true)
            }
        }
        
    }
    @IBAction func previousBtnAction(_ sender: Any) {
        
        if currentItem-1 >= 0 {
            
            currentItem     = currentItem-1
            let nextItem: IndexPath = IndexPath(item: currentItem, section: 0)
            if nextItem.row < myAdsArr.count && nextItem.row >= 0{
                homeCV.scrollToItem(at: nextItem, at: .right, animated: true)
            }
        }
    }
    
    // MARK: - UIButtonAction protocol
    
    @IBAction func actionProfile(_ sender: Any) {
        
        let  view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @IBAction func actionFilterBtn(_ sender: Any) {
        
        let alertController = UIAlertController(title: appNAME, message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "LAST 7 DAYS", style: .default){ action -> Void in
            
            self.sortBTN.setTitle("LAST 7 DAYS", for: .normal)
            self.sortBy  = "day"
            self.getDashboardData()
            
        }
        alertController.addAction(defaultAction)
        
        let action1 = UIAlertAction(title: "LAST MONTH", style: .default){ action -> Void in
            
            self.sortBTN.setTitle("LAST MONTH", for: .normal)
            self.sortBy  = "month"
            self.getDashboardData()
            
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "LAST YEAR", style: .default){ action -> Void in
            
            self.sortBTN.setTitle("LAST YEAR", for: .normal)
            self.sortBy  = "year"
            self.getDashboardData()
        }
        alertController.addAction(action2)
        
        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cnclAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
