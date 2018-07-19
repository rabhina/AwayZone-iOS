//
//  MyInterestVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class MyInterestVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -
    @IBOutlet weak var interestsTV: UITableView!
    @IBOutlet var selectedInterestLB: UILabel!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    
    var FlagIMGURL          = ""
    var interestDataArr     = NSArray()
    var selectedIndex       = -1
    var selectedInterestArr = NSMutableArray()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interestsTV.register(UINib(nibName: "CategoriesTVC", bundle: nil), forCellReuseIdentifier: "CategoriesTVC")
        interestsTV.register(UINib(nibName: "ItemsTVC", bundle: nil), forCellReuseIdentifier: "ItemsTVC")
        
        let culturesAll = NSMutableArray()
        for dict in objProfiledModel.interest {
            
            culturesAll.add((dict as! NSDictionary)["name"] as? String ?? "")
        }
        
        selectedInterestLB.text = "Selected Interests: \(culturesAll.componentsJoined(by: ", "))"
        
        self.getInterests()
        
    }
    
    func getInterests() -> Void {
        
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
                        
                        self.interestsTV.reloadData()
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
            if selectedInterestArr.count > 13 {
                utilClass.showAlertView(appNAME, "You can select upto 14 Interest Only", self)
            }
            else {
                selectedInterestArr.add(dict)

            }

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
        
        cell.categoryNameLB.text    = "Arts & Entertainment"
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
        interestsTV.reloadData()
    }
    
    //MARK: -
    
    @IBAction func actionBack(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProfileVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        
    }
    @IBAction func updateBtnAction(_ sender: Any) {
        
        if selectedInterestArr.count > 0 {
            updateIntereseSaveRcord()
            
        }
        
        if objEditModel.culture.count == 0 {
            utilClass.showAlertView(appNAME, "Please Select Cultures", self)
        }
        else if objEditModel.interest.count == 0{
            utilClass.showAlertView(appNAME, "Please Select Interests", self)
        }
        else {
            let paramDict = ["user_id" : utilClass.getUserID(),
                             "culture" : self.convertToJsonString(arr: objEditModel.culture),
                             "interest" : self.convertToJsonString(arr: objEditModel.interest),
                             "email" : objEditModel.email,
                             "lati" : objEditModel.lati,
                             "longi" : objEditModel.longi,
                             "full_name" : objEditModel.first_name,
                             "organization_name" : objEditModel.organisationName,
                             "contact_no" : objEditModel.contactNo,
                             "alias_name" : objEditModel.alias_name,
                             "user_description" : objEditModel.user_description,
                             ] as [String : Any]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KEditProfile, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        let alertView: UIAlertController = UIAlertController(title: appNAME , message: "Profile Updated Successfully!" as String, preferredStyle: .alert)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                            
                            self.actionBack(self)
                        }
                        alertView.addAction(cancelAction)
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            })
        }
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
    //MARK: - TopBarButtonActions
    
    func updateIntereseSaveRcord()  {
        
        let interestArr = NSMutableArray()
        for dict in selectedInterestArr{
            
            let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
            
            let ddd = ["interest" : idStr]
            interestArr.add(ddd)
            
        }
        objEditModel.interest   = interestArr
    }
    
    @IBAction func actionInterestBTn(_ sender: Any) {
        
    }
    @IBAction func actionAccountBtn(_ sender: Any) {
        
        if selectedInterestArr.count > 0 {
            updateIntereseSaveRcord()
            
        }
        
        var isAvailable     = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: EditProfileVC.self) {
                isAvailable =   true
                self.navigationController!.popToViewController(controller, animated: false)
                break
            }
        }
        if !isAvailable {
            let view  = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC")
            self.navigationController?.pushViewController(view!, animated: false)
        }
    }
    @IBAction func actionDetailsBtn(_ sender: Any) {
        
        if selectedInterestArr.count > 0 {
            updateIntereseSaveRcord()
            
        }
        
        var isAvailable     = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DetailsVC.self) {
                isAvailable =   true
                self.navigationController!.popToViewController(controller, animated: false)
                break
            }
        }
        if !isAvailable {
            let view  = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC")
            self.navigationController?.pushViewController(view!, animated: false)
        }
    }
    @IBAction func actionCultureBtn(_ sender: Any) {
        
        if selectedInterestArr.count > 0 {
            updateIntereseSaveRcord()
            
        }
        var isAvailable     = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MyCulturesVC.self) {
                isAvailable =   true
                self.navigationController!.popToViewController(controller, animated: false)
                break
            }
        }
        if !isAvailable {
            let view  = self.storyboard?.instantiateViewController(withIdentifier: "MyCulturesVC")
            self.navigationController?.pushViewController(view!, animated: false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
