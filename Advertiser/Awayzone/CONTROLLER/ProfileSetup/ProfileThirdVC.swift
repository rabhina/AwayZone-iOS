//
//  ProfileThirdVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage


class ProfileThirdVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -
    @IBOutlet weak var profileSetupTV: UITableView!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    
    var FlagIMGURL          = ""
    var interestDataArr     = NSArray()
    var selectedIndex       = -1
    var selectedInterestArr  = NSMutableArray()
    
    //MARK: - ViewMethods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileSetupTV.register(UINib(nibName: "CategoriesTVC", bundle: nil), forCellReuseIdentifier: "CategoriesTVC")
        profileSetupTV.register(UINib(nibName: "ItemsTVC", bundle: nil), forCellReuseIdentifier: "ItemsTVC")
        
        self.getCultures()
        
    }
    
    func getCultures() -> Void {
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingGET(methodName: KGetInterest as NSString, paramDictionary: nil) { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    
                    let dict = responseDict as NSDictionary
                    
                    if let culture_data = dict["interest_data"] as? NSArray {
                        self.interestDataArr    = culture_data
                        
                        self.profileSetupTV.reloadData()
                    }
                    else {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        
                    }
                }
            }
        }
    }
    //MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return interestDataArr.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == section {
            return ((interestDataArr[section] as! NSDictionary)["interests"] as! NSArray).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "ItemsTVC", for: indexPath) as! ItemsTVC
        
        cell.selectionStyle = .none
        cell.itemIMG.layer.cornerRadius = cell.itemIMG.frame.size.width/2
        cell.itemIMG.clipsToBounds      = true
        
        let resArr  = ((interestDataArr[indexPath.section] as! NSDictionary)["interests"] as! NSArray)
        
        let dict    = resArr[indexPath.row] as! NSDictionary
        cell.nameLB.text    = dict["name"] as? String ?? ""
        
        if selectedInterestArr.contains(dict) {
            cell.boxIMG.isHighlighted   = true
        }
        else {
            cell.boxIMG.isHighlighted   = false
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resArr  = ((interestDataArr[indexPath.section] as! NSDictionary)["interests"] as! NSArray)
        let dict    = resArr[indexPath.row] as! NSDictionary
        
        if selectedInterestArr.contains(dict) {
            selectedInterestArr.remove(dict)
        }
        else {
            selectedInterestArr.add(dict)
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "CategoriesTVC") as! CategoriesTVC
        cell.selectionStyle = .none
        
        cell.dropDownIMG.isHighlighted  = true
        if selectedIndex == section {
            cell.dropDownIMG.isHighlighted  =   false
        }
        
        
        cell.selectBtn.tag  = section
        cell.selectBtn.addTarget(self,action:#selector(actionSelectBtn),
                                 for:.touchUpInside)
        let resDict = (interestDataArr[section] as! NSDictionary)
        cell.categoryNameLB.text    = resDict["name"] as? String ?? ""
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    //MARK: - UICellBtnActions
    
    @objc func actionSelectBtn(sender: UIButton) -> Void {
        
        if selectedIndex == sender.tag {
            selectedIndex   = -1
        }
        else {
            selectedIndex   = sender.tag
        }
        profileSetupTV.reloadData()
    }
    
    //MARK: -
    
    @IBAction func actionFinishBtn(_ sender: Any) {
        
        if selectedInterestArr.count == 0 {
            self.utilClass.showAlertView(appNAME, "Select Intereset please!" as NSString, self)
        }
        else {
            let cultures = NSMutableArray()
            for dict in selectedInterestArr{
                
                let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
                
                let ddd = ["interest" : idStr]
                cultures.add(ddd)
                
            }
            
            objProfiledModel.interest    = cultures
            print(cultures)
            userSignup()
        }
    }
    
    func userSignup() -> Void {
        
        let paramDict = ["culture"      :self.convertToJsonString(arr: objProfiledModel.culture),
                         "user_id"      :objProfiledModel.id,
                         "interest"     :self.convertToJsonString(arr: objProfiledModel.interest),
                         "email"        :objProfiledModel.email,
                         "lati"         :objProfiledModel.lati,
                         "longi"         :objProfiledModel.longi,
                         "full_name"    :objProfiledModel.first_name,
                         "organization_name"  :objProfiledModel.organisationName,
                         "contact_no"    :objProfiledModel.contactNo
        ]
        
        print(paramDict)
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KFullRegistration, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let bodyDict = responseDict as NSDictionary
                    let codestr     = bodyDict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME,"" , self)
                    }
                    else {
                        if let userID     = bodyDict.object(forKey: "user_id") as? String {
                            Utilities.sharedInstance.setUserID(userID as NSString)
                            
                        }
                        else if let userID     = bodyDict.object(forKey: "user_id") as? Int {
                            Utilities.sharedInstance.setUserID("\(userID)" as NSString)
                            
                        }
                        
                        let defaults    = UserDefaults.standard
                        defaults.set(bodyDict.object(forKey: "email"),      forKey: "Email")
                        defaults.set(bodyDict.object(forKey: "first_name"), forKey: "Name")
                        defaults.set("1",        forKey: "full_reg")
                        defaults.set(bodyDict.object(forKey: "image"),       forKey: "image")
                        defaults.set(bodyDict.object(forKey: "image_url"),   forKey: "image_url")
                        defaults.set(bodyDict.object(forKey: "contact_no"),   forKey: "contact_no")
                        defaults.set(bodyDict.object(forKey: "organization_name"),   forKey: "organization_name")
                        
                        if let imgData = UIImageJPEGRepresentation(objProfiledModel.userIMG, 0.2) {
                            self.uploadImage(pickedIm: imgData as NSData)
                            
                        }
                        else {
                            
                            objProfiledModel = ProfileSetupModel()
                            objProfiledModel.setupProfileUSer(dict: responseDict)
                            
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeViews")
                            self.view.window?.rootViewController = view
                        }
                    }
                }
            }
        })
    }
    
    func uploadImage(pickedIm: NSData) -> Void {
        
        let paramDict = ["id"     :utilClass.getUserID()] as NSDictionary
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        
        WebserviceClass.sharedInstance.UploadRequest(methodName: KUploadIMG, paramDictionary: paramDict, image_data: pickedIm, imageParameter: "file") { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeViews")
                    self.view.window?.rootViewController = view
                }
            }
        }
    }
    
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
    
    
    @IBAction func actionBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
