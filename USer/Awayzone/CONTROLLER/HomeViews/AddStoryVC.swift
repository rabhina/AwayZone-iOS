//
//  AddStoryVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 07/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class AddStoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextViewDelegate {

    @IBOutlet var searchBarTF: UISearchBar!
    @IBOutlet var usersTV: UITableView!
    @IBOutlet var descTxV: UITextView!
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    var iMGURL  =   String()
    
    var searchArr   = NSMutableArray()
    var allUSersArr = NSMutableArray()
    var selectedArr = NSMutableArray()
    
    var imageOrVideo    = NSString()
    var selectedIMG = NSData()
    var detailsDict = NSDictionary()
    
    var storyDetailsDict    = NSMutableDictionary()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        descTxV.delegate        = self
        searchBarTF.delegate    = self
        getAllUSers()
        
        if self.title == "Update"
        {
            descTxV.text    = storyDetailsDict["caption"] as? String ?? ""
            
        }
        
    }
    
    //MARK: - GetComments
    
    func getAllUSers() -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID()] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KGetAllUsers, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if let imgUrl   = responseDict["image_url"] as? String {
                    self.iMGURL  =   imgUrl
                }
                
                if let comment  = responseDict["all_user_arr"] as? NSArray {
                    self.allUSersArr   = comment as! NSMutableArray
                    self.searchArr     = comment as! NSMutableArray
                    self.usersTV.reloadData()
                }
                else {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
            }
        })
        
    }
    
    //MARK: -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.selectionStyle = .none
        
        let dict    = searchArr[indexPath.row] as! NSDictionary
        
        cell.userIMG.sd_setImage(with: URL(string: "\(iMGURL)\(dict["profile_image"] as? String ?? "")")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        
        cell.userIMG.clipsToBounds  = true
        cell.userIMG.layer.cornerRadius = cell.userIMG.frame.size.width/2.0
        
        cell.nameLB.text    = dict["first_name"] as? String ?? ""
        cell.selectIMG.isHighlighted    = false
        
        if selectedArr.contains(dict) {
            cell.selectIMG.isHighlighted    = true
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight    = 50
        return UITableViewAutomaticDimension
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dict    = searchArr[indexPath.row] as! NSDictionary

        if selectedArr.contains(dict) {
            selectedArr.remove(dict)
        }
        else {
            selectedArr.add(dict)
        }
        tableView.reloadData()
    }
    
    // MARK: - UIButtonActions
    
    
    @IBAction func actionBackBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func publishBtnAction(_ sender: Any) {
        
        if self.title == "Update" {
            self.updateStory()
        }
        else {
            
            if imageOrVideo == "image" {
                addNEwStory()
            }
            else {
                addNEwStoryWithVideo()
            }
        }
        
    }
    
    
    func updateStory() -> Void {
        
        let detailsDict = storyDetailsDict as NSDictionary
        let paramDict = ["user_id" : self.utilClass.getUserID(),
                         "ad_id"   : "\(detailsDict["ad_id"]!)",
            "type"   : "edit",
            "caption": descTxV.text!,
            "story_id": "\(detailsDict["story_id"]!)",
            ] as [String : Any]
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KUpdateStory, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                
                let dict = responseDict as NSDictionary
                let codestr     = dict.object(forKey: "status") as! String
                
                if codestr .isEqual("0"){
                    
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Story Updated Succesfully!" as String, preferredStyle: .alert)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertView.addAction(cancelAction)
                    self.present(alertView, animated: true, completion: nil)
                }
                
            }
        })
        
    }
    
    
    func addNEwStory() -> Void {
        
        if selectedArr.count == 0 {
            self.utilClass.showAlertView(appNAME, "Select Users please!" as NSString, self)
        }
        else {
            let cultures = NSMutableArray()
            for dict in selectedArr{
                
                let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
                
                let ddd = ["user_id" : idStr]
                cultures.add(ddd)
                
            }
            
            let paramDict = ["user_id"     :utilClass.getUserID(),
                             "tag"     :self.convertToJsonString(arr: cultures),
                             "ad_id" : "\(detailsDict["ad_id"]!)",
                             "caption": descTxV.text!
                ] as NSDictionary
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            
            WebserviceClass.sharedInstance.UploadRequest(methodName: KAddStory, paramDictionary: paramDict, image_data: selectedIMG, imageParameter: "image") { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                    }
                    else {
                        let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Story Added Succesfully!" as String, preferredStyle: .alert)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertView.addAction(cancelAction)
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func addNEwStoryWithVideo() -> Void {
        
        if selectedArr.count == 0 {
            self.utilClass.showAlertView(appNAME, "Select Users please!" as NSString, self)
        }
        else {
            let cultures = NSMutableArray()
            for dict in selectedArr{
                
                let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
                
                let ddd = ["user_id" : idStr]
                cultures.add(ddd)
                
            }
            
            let paramDict = ["user_id"     :utilClass.getUserID(),
                             "tag"     :self.convertToJsonString(arr: cultures),
                             "ad_id" : "\(detailsDict["ad_id"]!)",
                "caption": descTxV.text!
                ] as NSDictionary
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            
            
            WebserviceClass.sharedInstance.UploadRequestForVideo(methodName: KAddStory, paramDictionary: paramDict, image_data: selectedIMG, imageParameter: "image") { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                    }
                    else {
                        let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Story Added Succesfully!" as String, preferredStyle: .alert)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertView.addAction(cancelAction)
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    //MARK: - SearchBarDelegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchArr   = NSMutableArray()
        usersTV.reloadData()
        
        for dict in allUSersArr {
            
            if (((dict as! NSDictionary)["first_name"] as! String).lowercased()).range(of:searchText.lowercased()) != nil {
                
                searchArr.add(dict)
            }
        }
        usersTV.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchArr   = NSMutableArray()
        
        searchBar.showsCancelButton = false
        
        self.view.endEditing(true)
        searchArr   = allUSersArr
        usersTV.reloadData()
    }
    
    
    //MARK:- TextView Delegate
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
 
        return textView.text.count + (text.count - range.length) <= 60
    }
    
    //MARK: -
    func convertToJsonString(arr : NSArray) -> String {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arr, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return JSONString
            }
        } catch {
            return ""
            
        }
        return ""
    }
    
    // MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
