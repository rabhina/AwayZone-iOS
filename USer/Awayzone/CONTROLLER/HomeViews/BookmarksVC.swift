//
//  BookmarksVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class BookmarksVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    //MARK: -
    
    @IBOutlet var titleLB: UILabel!
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    var iMGURL          = String()
    var allDataArr  = NSMutableArray()
    var searchArr   = NSMutableArray()
    
    //MARK: -
    
    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet var bookMArkCV: UICollectionView!
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookMArkCV.keyboardDismissMode = .onDrag

        self.bookMArkCV.register(UINib(nibName: "AdsCVC", bundle: nil), forCellWithReuseIdentifier: "AdsCVC")
        self.getStories()
        
        titleLB.text    = self.title?.uppercased()
    }
    
    func getStories() -> Void {
        
        let paramDict = ["id"     :utilClass.getUserID(),
                         "type"   :self.title ?? ""
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KViewAll, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                if let image_url    = dict["image_url"] as? String {
                    self.iMGURL  = image_url
                }
                if let storydata = dict["location"] as? NSArray {
                    self.allDataArr    = storydata as! NSMutableArray
                    self.searchArr      = storydata as! NSMutableArray
                    self.bookMArkCV.reloadData()
                }
                else {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
            }
        })
    }
    
    
    //MARK: -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCVC", for: indexPath as IndexPath) as! BookmarkCVC

        let dict    = searchArr[indexPath.row] as! NSDictionary
        
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
        
        cell.bookmarkBTN.addTarget(self,action:#selector(actionBookMarkBtn(sender:)), for:.touchUpInside)
        cell.beenhereBTN.addTarget(self,action:#selector(actionBeenHereBtn(sender:)), for:.touchUpInside)
        cell.likeBTN.addTarget(self,action:#selector(actionLikeBtn(sender:)), for:.touchUpInside)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.size.width/2)-5 , height: 240)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let  view = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        view.detailsDict    = (searchArr[indexPath.row] as! NSDictionary) as! NSMutableDictionary
        view.iMGURL = iMGURL
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    //MARK: -
    
    @IBAction func actionBackBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionFilterBTn(_ sender: Any) {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "SORT BY MAGIC", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        let action1 = UIAlertAction(title: "SORT BY POPULARITY", style: .default, handler: nil)
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "SORT BY RATING", style: .default, handler: nil)
        alertController.addAction(action2)
        
        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cnclAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - UICellBtnActions
    
    @objc func actionBookMarkBtn(sender: UIButton) -> Void {
        
        let dict    = searchArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "bookmark")
        
    }
    @objc func actionBeenHereBtn(sender: UIButton) -> Void {
        
        let dict    = searchArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "been")
    }
    
    @objc func actionLikeBtn(sender: UIButton) -> Void {
        
        let dict    = searchArr[sender.tag]
        self.likeBeenBookmark(dict: dict as! NSDictionary, type: "like")
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
                    self.getStories()
                }
            }
        })
    }
    
    //MARK: - SearchBarDelegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchArr   = NSMutableArray()
        bookMArkCV.reloadData()
        
        for dict in allDataArr {
            
            if (((dict as! NSDictionary)["title"] as! String).lowercased()).range(of:searchText.lowercased()) != nil {
                
                searchArr.add(dict)
            }
        }
        bookMArkCV.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchArr   = NSMutableArray()
        
        searchBar.showsCancelButton = false

        self.view.endEditing(true)
        searchArr   = allDataArr
        bookMArkCV.reloadData()
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
