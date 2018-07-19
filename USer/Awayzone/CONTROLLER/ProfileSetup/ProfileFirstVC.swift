//
//  ProfileFirstVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage
import GooglePlaces

class ProfileFirstVC: UIViewController {

    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var cultureTV: UITableView!
    
    //MARK: -
    var selectedLatitude     = ""
    var selectedLongitude    = ""
    var selectedIndex = -1

    var selectedCultureArr   = NSMutableArray()
    
    var FlagIMGURL      = ""
    var culturesDataArr = NSArray()
    
    var pickedIm = NSData()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        cultureTV.register(UINib(nibName: "CategoriesTVC", bundle: nil), forCellReuseIdentifier: "CategoriesTVC")
        cultureTV.register(UINib(nibName: "ItemsTVC", bundle: nil), forCellReuseIdentifier: "ItemsTVC")
        
        emailTF.text    =   objProfiledModel.email
        emailTF.isUserInteractionEnabled    = false
        self.getCultures() 
        
    }
    
    func getCultures() -> Void {
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingGET(methodName: KGetCultures as NSString, paramDictionary: nil) { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                if let imgUrl   = dict["image_url"] as? String{
                    
                    self.FlagIMGURL  = imgUrl
                }
                if let culture_data = dict["culture_data"] as? NSArray {
                    self.culturesDataArr    = culture_data
                    
                    self.cultureTV.reloadData()
                }
                else {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        userIMG.layer.cornerRadius  = userIMG.frame.size.width/2.0
        userIMG.clipsToBounds       = true
    }
    
    //MARK: - ButtonActions

    @IBAction func actionUpdatePic(_ sender: Any) {
        
        let alertView: UIAlertController = UIAlertController(title: "" as String, message: "Upload Picture!!" as String, preferredStyle: .actionSheet)
        
        let galleryAction: UIAlertAction = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        }
        
        alertView.addAction(galleryAction)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take New Photo", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerControllerSourceType.camera;
                imag.allowsEditing = true
                
                self.present(imag, animated: true, completion: nil)
                
            }
        }
        alertView.addAction(cameraAction)
        
        let cnclAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive) { action -> Void in
        }
        alertView.addAction(cnclAction)
        
        self.present(alertView, animated: true, completion: nil)

    }
    
    @IBAction func nextBtnAction(_ sender: Any) {
        
        if selectedLongitude == "" {
            utilClass.showAlertView(appNAME, "Please Select Location", self)
            
        }
        else if (usernameTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter username", self)
        }
        else if pickedIm.length == 0{
            utilClass.showAlertView(appNAME, "Please select User Image", self)
        }
        else if selectedCultureArr.count == 0 {
            utilClass.showAlertView(appNAME, "Please select Culture", self)

        }
        else {
            objProfiledModel.lati   = selectedLatitude
            objProfiledModel.longi  = selectedLongitude
            objProfiledModel.first_name = usernameTF.text!
            objProfiledModel.userIMG    = userIMG.image!
            objProfiledModel.culture_id = "\((selectedCultureArr[0] as! NSDictionary).object(forKey: "culture_category_id")!)"
            objProfiledModel.user_culture = "\((selectedCultureArr[0] as! NSDictionary).object(forKey: "id")!)"

            
            
            let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSecondVC") as! ProfileSecondVC
            self.navigationController?.pushViewController(view, animated: true)
        }
    }
    
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}



extension ProfileFirstVC : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
         if textField == locationTF {
                        
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
extension ProfileFirstVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        locationTF.text = "\(place.formattedAddress!)"
        
        selectedLatitude    = "\(place.coordinate.latitude)"
        selectedLongitude   = "\(place.coordinate.longitude)"
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension ProfileFirstVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - ImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userIMG.image   = pickedImage
            pickedIm = UIImageJPEGRepresentation(pickedImage, 0.2)! as NSData
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension ProfileFirstVC: UITableViewDelegate, UITableViewDataSource {

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
        else {
            cell.boxIMG.isHighlighted   = false
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCultureArr  = NSMutableArray()
        let resArr  = ((culturesDataArr[indexPath.section] as! NSDictionary)["cultures"] as! NSArray)
        
        let dict    = resArr[indexPath.row] as! NSDictionary
        selectedCultureArr.add(dict)
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
        cultureTV.reloadData()
    }
}


