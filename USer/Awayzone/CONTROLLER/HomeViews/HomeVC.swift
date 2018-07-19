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
    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var homeCV: UICollectionView!
    
    //MARK: -
    
    var recomendedArr   = NSMutableArray()
    var culturesArr     = NSMutableArray()
    var locationsArr    = NSMutableArray()
    var iMGURL          = String()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeCV.register(UINib(nibName: "FooterCVC", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterCVC")
        homeCV.register(UINib(nibName: "HeaderCVC", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDashboardData()
        if "\(objProfiledModel.image_url)\(objProfiledModel.image)" != "" {
            userIMG.sd_setImage(with: URL(string: "\(objProfiledModel.image_url)\(objProfiledModel.image)")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
        }
    }
    
    func getDashboardData() -> Void {
        
        let paramDict = ["id" : utilClass.getUserID()]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KDashboard, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if let imgUrl   = responseDict["image_url"] as? String{
                    self.iMGURL  = imgUrl
                }
                
                let dict = responseDict as NSDictionary
                
                if let recommen = dict["recommended"] as? NSArray {
                    self.recomendedArr  = NSMutableArray()
                    self.recomendedArr.addObjects(from: recommen as! [Any])
                }
                
                if let location = dict["location"] as? NSArray {
                    self.locationsArr  = NSMutableArray()
                    self.locationsArr.addObjects(from: location as! [Any])
                }
                
                if let culture = dict["culture"] as? NSArray {
                    self.culturesArr  = NSMutableArray()
                    self.culturesArr.addObjects(from: culture as! [Any])
                }
                
                self.homeCV.reloadData()
            }
        })
    }
    
    // MARK: -
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return recomendedArr.count
            
        }
        else if section == 2 {
            return culturesArr.count
            
        }
        else if section == 3 {
            return locationsArr.count
            
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCVC", for: indexPath as IndexPath) as! SliderCVC
            
            for index in 0...2 {
                
                let frameX  = Int(index * Int(cell.scrollVi.frame.size.width))
                
                let imageView  = UIImageView(frame:CGRect(x:frameX, y:0, width:Int(collectionView.frame.size.width), height:240));
                imageView.image = UIImage(named:"BACKGROUND")
                cell.scrollVi.addSubview(imageView)
            }
            
            cell.scrollVi.contentSize   = CGSize.init(width: Int(3 * Int(cell.scrollVi.frame.size.width)), height: 240)
            cell.scrollVi.isPagingEnabled   = true
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCVC", for: indexPath as IndexPath) as! CategoriesCVC
            
            var dict    = NSDictionary()
            
            if indexPath.section == 1 {
                dict    = recomendedArr[indexPath.row] as! NSDictionary
                cell.bookmarkBTN.removeTarget(self,action:#selector(actionBookMarkBtn(sender:)), for:.touchUpInside)
                cell.beenhereBTN.removeTarget(self,action:#selector(actionBeenHereBtn(sender:)), for:.touchUpInside)
                cell.likeBTN.removeTarget(self,action:#selector(actionLikeBtn(sender:)), for:.touchUpInside)
                
                cell.bookmarkBTN.addTarget(self,action:#selector(actionBookMarkBtn(sender:)), for:.touchUpInside)
                
                cell.beenhereBTN.addTarget(self,action:#selector(actionBeenHereBtn(sender:)), for:.touchUpInside)
                cell.likeBTN.addTarget(self,action:#selector(actionLikeBtn(sender:)), for:.touchUpInside)
                
            }
            else if indexPath.section   == 2 {
                dict    = culturesArr[indexPath.row] as! NSDictionary
                
                cell.bookmarkBTN.removeTarget(self,action:#selector(actionBookMarkBtn1(sender:)), for:.touchUpInside)
                
                cell.beenhereBTN.removeTarget(self,action:#selector(actionBeenHereBtn1(sender:)), for:.touchUpInside)
                cell.likeBTN.removeTarget(self,action:#selector(actionLikeBtn1(sender:)), for:.touchUpInside)
                
                cell.bookmarkBTN.addTarget(self,action:#selector(actionBookMarkBtn1(sender:)), for:.touchUpInside)
                
                cell.beenhereBTN.addTarget(self,action:#selector(actionBeenHereBtn1(sender:)), for:.touchUpInside)
                cell.likeBTN.addTarget(self,action:#selector(actionLikeBtn1(sender:)), for:.touchUpInside)
                
            }
            else if indexPath.section   == 3 {
                dict    = locationsArr[indexPath.row] as! NSDictionary
                
                
                cell.bookmarkBTN.removeTarget(self,action:#selector(actionBookMarkBtn2(sender:)), for:.touchUpInside)
                
                cell.beenhereBTN.removeTarget(self,action:#selector(actionBeenHereBtn2(sender:)), for:.touchUpInside)
                cell.likeBTN.removeTarget(self,action:#selector(actionLikeBtn2(sender:)), for:.touchUpInside)
                
                cell.bookmarkBTN.addTarget(self,action:#selector(actionBookMarkBtn2(sender:)), for:.touchUpInside)
                
                cell.beenhereBTN.addTarget(self,action:#selector(actionBeenHereBtn2(sender:)), for:.touchUpInside)
                cell.likeBTN.addTarget(self,action:#selector(actionLikeBtn2(sender:)), for:.touchUpInside)
                
            }
            
            
            cell.commentBTN.setTitle("\(dict["comment"]!)", for: .normal)
            cell.likeBTN.setTitle("\(dict["likes"]!)", for: .normal)
            cell.ratingBTN.setTitle("(\(dict["rating"]!))", for: .normal)
            
            cell.commentBTN.setTitle("\(dict["comment"]!)", for: .normal)
            cell.nameLB.text    = "\(dict["title"]!)"
            
            cell.categoryIMG.sd_setImage(with: URL(string: "\(iMGURL)\(dict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
            
            if let bookmark     = dict["user_bookmark"] as? Bool {
                if bookmark {
                    cell.bookmarkBTN.isSelected = true
                    cell.bookmarkBTN.layer.backgroundColor  = UIColor.init(red: 218/255.0, green: 78/255.0, blue: 0/255.0, alpha: 1).cgColor
                }
                else {
                    cell.bookmarkBTN.isSelected = false
                    cell.bookmarkBTN.layer.backgroundColor  = UIColor.white.cgColor
                }
            }
            
            if let beenhere     = dict["user_been_here"] as? Bool {
                if beenhere {
                    cell.beenhereBTN.isSelected = true
                    cell.beenhereBTN.layer.backgroundColor  = UIColor.init(red: 32/255.0, green: 117/255.0, blue: 211/255.0, alpha: 1).cgColor
                }
                else {
                    cell.beenhereBTN.isSelected = false
                    cell.beenhereBTN.layer.backgroundColor  = UIColor.white.cgColor
                }
            }
            
            if let like     = dict["user_likes"] as? Bool {
                if like {
                    cell.likeBTN.isSelected = true
                }
                else {
                    cell.likeBTN.isSelected = false
                }
            }
            
            cell.bookmarkBTN.tag  = indexPath.row
            cell.beenhereBTN.tag  = indexPath.row
            cell.likeBTN.tag  = indexPath.row
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section    == 0{
            return CGSize(width: (collectionView.frame.size.width) , height: 240)
        }
        else {
            return CGSize(width: (collectionView.frame.size.width/2)-5 , height: 250)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    //MARK: - Header
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableview = UICollectionReusableView()
        if (kind == UICollectionElementKindSectionHeader) {
            if indexPath.section != 0 {
                
                let firstheader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCVC", for: indexPath) as! HeaderCVC
                if indexPath.section == 0 {
                    firstheader.titleLB.text    = ""
                }
                else if indexPath.section == 1 {
                    firstheader.titleLB.text    = "Recommended".uppercased()
                    firstheader.titleLB.textColor   = UIColor.init(red: 218/255.0, green: 78/255.0, blue: 0/255.0, alpha: 1)
                    
                }
                else if indexPath.section == 2 {
                    firstheader.titleLB.text    = "Culture".uppercased()
                    firstheader.titleLB.textColor   = UIColor.init(red: 74/255.0, green: 170/255.0, blue: 191/255.0, alpha: 1)
                    
                }
                else if indexPath.section == 3 {
                    firstheader.titleLB.text    = "Location".uppercased()
                    firstheader.titleLB.textColor   =  UIColor.init(red: 232/255.0, green: 185/255.0, blue: 63/255.0, alpha: 1)
                    
                }
                
                reusableview = firstheader
            }
        }
        else if (kind == UICollectionElementKindSectionFooter) {
            
            if indexPath.section != 0 {
                let  firstheader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterCVC", for: indexPath) as! FooterCVC
                
                if indexPath.section == 1 {
                    firstheader.viewAllBTN.setTitle("VIEW ALL RECOMMENDATION", for: .normal)
                    firstheader.viewAllBTN.layer.backgroundColor   = UIColor.init(red: 218/255.0, green: 78/255.0, blue: 0/255.0, alpha: 1).cgColor
                    
                    firstheader.viewAllBTN.removeTarget(self,action:#selector(viewAllRecommended(sender:)), for:.touchUpInside)
                    
                firstheader.viewAllBTN.addTarget(self,action:#selector(viewAllRecommended(sender:)), for:.touchUpInside)
                    
                }
                else if indexPath.section == 2 {
                    firstheader.viewAllBTN.setTitle("VIEW ALL CULTURE", for: .normal)
                    firstheader.viewAllBTN.layer.backgroundColor   = UIColor.init(red: 74/255.0, green: 170/255.0, blue: 191/255.0, alpha: 1).cgColor

                    firstheader.viewAllBTN.removeTarget(self,action:#selector(viewAllCutures(sender:)), for:.touchUpInside)

                    firstheader.viewAllBTN.addTarget(self,action:#selector(viewAllCutures(sender:)), for:.touchUpInside)
                    
                }
                else if indexPath.section == 3 {
                    firstheader.viewAllBTN.setTitle("VIEW ALL LOCATION BASED", for: .normal)
                    firstheader.viewAllBTN.layer.backgroundColor   = UIColor.init(red: 232/255.0, green: 185/255.0, blue: 63/255.0, alpha: 1).cgColor
                    
                    firstheader.viewAllBTN.removeTarget(self,action:#selector(viewAllLocations(sender:)), for:.touchUpInside)
                    firstheader.viewAllBTN.addTarget(self,action:#selector(viewAllLocations(sender:)), for:.touchUpInside)
                    
                }
                
                reusableview = firstheader
            }
        }
        return reusableview
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if(section==0) {
            return CGSize.zero
        } else {
            return CGSize(width:collectionView.frame.size.width-5, height:30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if(section==0) {
            return CGSize.zero
        } else {
            return CGSize(width:collectionView.frame.size.width-5, height:50)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            return
        }
        
        var dict    = NSDictionary()
        
        if indexPath.section == 1 {
            dict    = recomendedArr[indexPath.row] as! NSDictionary
        }
        else if indexPath.section   == 2 {
            dict    = culturesArr[indexPath.row] as! NSDictionary
        }
        else if indexPath.section   == 3 {
            dict    = locationsArr[indexPath.row] as! NSDictionary
        }
        
        let  view = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        view.detailsDict    = dict as! NSMutableDictionary
        view.iMGURL = iMGURL
        self.navigationController?.pushViewController(view, animated: true)
        
    }
    
    @IBAction func actionProfile(_ sender: Any) {
        
        let  view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    //MARK: - UICellBtnActions
    
    @objc func actionBookMarkBtn(sender: UIButton) -> Void {
        
        let dict    = recomendedArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "bookmark")
        
    }
    @objc func actionBeenHereBtn(sender: UIButton) -> Void {
        
        let dict    = recomendedArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "been")
    }
    
    @objc func actionLikeBtn(sender: UIButton) -> Void {
        
        let dict    = recomendedArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "like")
    }
    
    @objc func actionBookMarkBtn1(sender: UIButton) -> Void {
        
        let dict    = culturesArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "bookmark")
        
    }
    @objc func actionBeenHereBtn1(sender: UIButton) -> Void {
        
        let dict    = culturesArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "been")
    }
    
    @objc func actionLikeBtn1(sender: UIButton) -> Void {
        
        let dict    = culturesArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "like")
    }
    
    
    @objc func actionBookMarkBtn2(sender: UIButton) -> Void {
        
        let dict    = locationsArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "bookmark")
        
    }
    @objc func actionBeenHereBtn2(sender: UIButton) -> Void {
        
        let dict    = locationsArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "been")
    }
    
    @objc func actionLikeBtn2(sender: UIButton) -> Void {
        
        let dict    = locationsArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "like")
    }
    
    
    //MARK: - HeadreCell
    
    
    @objc func viewAllCutures(sender: UIButton) -> Void {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        view.title  = "culture"
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func viewAllLocations(sender: UIButton) -> Void {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        view.title  = "location"
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func viewAllRecommended(sender: UIButton) -> Void {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        view.title  =  "recommended"
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func likeBeenBookmark(dict : NSDictionary, type: String) -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID(),
                         "ad_id"   : "\(dict["ad_id"]!)",
            "type"   : type
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KLikeBeenBookMark, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                let codestr     = dict.object(forKey: "status") as! String
                
                if codestr .isEqual("0"){
                    
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    self.getDashboardData()
                }
            }
        })
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
