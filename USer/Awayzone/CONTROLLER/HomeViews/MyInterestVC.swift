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
        WebserviceClass.sharedInstance.apiCallWithParametersUsingGET(methodName: KGetInterest as NSString, paramDictionary: nil) { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
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
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func updateBtnAction(_ sender: Any) {
        
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
            
            let paramDict = ["user_id"     :utilClass.getUserID(),
                             "interest"     :self.convertToJsonString(arr: cultures)
                ] as [String : Any]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KEditInterest, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String

                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                    }
                    else {
                        let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Your Interest Updated Successfully!" as String, preferredStyle: .alert)
                        
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                            self.navigationController?.popViewController(animated: true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
