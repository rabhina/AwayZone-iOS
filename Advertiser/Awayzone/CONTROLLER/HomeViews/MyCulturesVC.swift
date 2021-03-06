//
//  MyCulturesVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class MyCulturesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: -
    @IBOutlet weak var culturesTV: UITableView!
    @IBOutlet var selectedCultureLB: UILabel!
    
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    
    var FlagIMGURL          = ""
    var culturesDataArr     = NSArray()
    var selectedIndex       = -1
    var selectedCultureArr  = NSMutableArray()
    
    //MARK: - ViewMethods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        culturesTV.register(UINib(nibName: "CategoriesTVC", bundle: nil), forCellReuseIdentifier: "CategoriesTVC")
        culturesTV.register(UINib(nibName: "ItemsTVC", bundle: nil), forCellReuseIdentifier: "ItemsTVC")
        
        let culturesAll = NSMutableArray()
        for dict in objProfiledModel.culture {
            
            culturesAll.add((dict as! NSDictionary)["cul_name"] as? String ?? "")
        }
        selectedCultureLB.text = "Selected Cultures: \(culturesAll.componentsJoined(by: ", "))"
        
        self.getCultures()
        
    }
    
    func getCultures() -> Void {
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingGET(methodName: KGetCultures as NSString, paramDictionary: nil) { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    if let imgUrl   = dict["image_url"] as? String{
                        
                        self.FlagIMGURL  = imgUrl
                    }
                    if let culture_data = dict["culture_data"] as? NSArray {
                        self.culturesDataArr    = culture_data
                        
                        self.culturesTV.reloadData()
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
        return culturesDataArr.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == section {
            return ((culturesDataArr[section] as! NSDictionary)["cultures"] as! NSArray).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "ItemsTVC", for: indexPath) as! ItemsTVC
        
        cell.selectionStyle = .none
        cell.itemIMG.layer.cornerRadius = cell.itemIMG.frame.size.width/2
        cell.itemIMG.clipsToBounds      = true
        
        let resArr  = ((culturesDataArr[indexPath.section] as! NSDictionary)["cultures"] as! NSArray)
        
        let dict    = resArr[indexPath.row] as! NSDictionary
        cell.nameLB.text    = dict["cul_name"] as? String ?? ""
        
        cell.itemIMG.sd_setImage(with: URL(string: "\(FlagIMGURL)\(dict["flag_image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        
        if selectedCultureArr.contains(dict) {
            cell.boxIMG.isHighlighted   = true
        }
        else
        {
            cell.boxIMG.isHighlighted   = false
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resArr  = ((culturesDataArr[indexPath.section] as! NSDictionary)["cultures"] as! NSArray)
        
        let dict    = resArr[indexPath.row] as! NSDictionary
        
        if selectedCultureArr.contains(dict) {
            selectedCultureArr.remove(dict)
        }
        else {
            if selectedCultureArr.count > 13 {
                utilClass.showAlertView(appNAME, "You can Select Maximum of 14 Cultures", self)
            }
            else {
                selectedCultureArr.add(dict)
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
        cell.selectBtn.tag  = section
        cell.selectBtn.addTarget(self,action:#selector(actionSelectBtn),
                                 for:.touchUpInside)
        
        let resDict = (culturesDataArr[section] as! NSDictionary)
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
        culturesTV.reloadData()
    }
    
    //MARK: - BackBtn
    
    @IBAction func actionBackBtn(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProfileVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func updateBtnAction(_ sender: Any) {
        
        updateCulturesSaveRecord()
        
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
                            
                            self.actionBackBtn(self)
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
    
    func updateCulturesSaveRecord()  {
        
        if selectedCultureArr.count > 0 {
            let cultures = NSMutableArray()
            for dict in selectedCultureArr{
                let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
                let ddd = ["culture" : idStr]
                cultures.add(ddd)
            }
            
            objEditModel.culture   = cultures
        }
    }
    
    
    @IBAction func actionInterestBTn(_ sender: Any) {
        
        updateCulturesSaveRecord()
        
        var isAvailable     = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MyInterestVC.self) {
                isAvailable =   true
                self.navigationController!.popToViewController(controller, animated: false)
                break
            }
        }
        if !isAvailable {
            let view  = self.storyboard?.instantiateViewController(withIdentifier: "MyInterestVC")
            self.navigationController?.pushViewController(view!, animated: false)
        }
    }
    @IBAction func actionAccountBtn(_ sender: Any) {
        
        updateCulturesSaveRecord()
        
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
        
        updateCulturesSaveRecord()
        
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
