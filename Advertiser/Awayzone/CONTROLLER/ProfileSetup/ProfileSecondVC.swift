//
//  ProfileSecondVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileSecondVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -
    @IBOutlet weak var porfileSetupTV: UITableView!
    
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
        
        porfileSetupTV.register(UINib(nibName: "CategoriesTVC", bundle: nil), forCellReuseIdentifier: "CategoriesTVC")
        porfileSetupTV.register(UINib(nibName: "ItemsTVC", bundle: nil), forCellReuseIdentifier: "ItemsTVC")
        
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
                            
                            self.porfileSetupTV.reloadData()
                        }
                        else {
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                            
                        }
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
            selectedCultureArr.add(dict)
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
        porfileSetupTV.reloadData()
    }
    
    @IBAction func actyionNextBtn(_ sender: Any) {
        
        if selectedCultureArr.count == 0 {
            self.utilClass.showAlertView(appNAME, "Select cultures please!" as NSString, self)
            
        }
        else {
            let cultures = NSMutableArray()
            for dict in selectedCultureArr{
               
                let idStr   = "\((dict as! NSDictionary).object(forKey: "id")!)"
                
                let ddd = ["culture" : idStr]
                cultures.add(ddd)
                
            }
            objProfiledModel.culture    = cultures
            let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileThirdVC") as! ProfileThirdVC
            self.navigationController?.pushViewController(view, animated: true)

        }
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
