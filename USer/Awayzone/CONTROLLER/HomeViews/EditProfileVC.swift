//
//  EditProfileVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage
import GooglePlaces

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var userIMG: UIImageView!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
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
        
        emailTF.text    = objProfiledModel.email
        usernameTF.text = objProfiledModel.first_name
        locationTF.text = objProfiledModel.lat_long_city
        
        var latt    = objProfiledModel.lati
        if latt == "" {
            latt = "0.00"
        }
        var long    = objProfiledModel.longi
        if long == "" {
            long = "0.00"
        }
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: Double(latt)!, longitude: Double(long)!)) { placemarks, error in
            guard let _ = placemarks?.first, error == nil else {

                return
            }
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary as Any)
            
            self.locationTF.text = placeMark.name ?? ""
        }
        
        self.getCultures()
        
        if "\(objProfiledModel.image_url)\(objProfiledModel.image)" != "" {
            userIMG.sd_setImage(with: URL(string: "\(objProfiledModel.image_url)\(objProfiledModel.image)")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
        }        
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
    
    @IBAction func updateProfile(_ sender: Any) {
        
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
    
    //MARK: - UIButtonActions
    
    @IBAction func actionBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func updateBtnAction(_ sender: Any) {
        
        if selectedLongitude == "" {
            utilClass.showAlertView(appNAME, "Please Select Location", self)
            
        }
        else if !utilClass.isValidEmail(testStr: emailTF.text!) {
            utilClass.showAlertView(appNAME, "Please enter valid email", self)
            
        }
        else if (usernameTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter username", self)
        }
        else if selectedCultureArr.count == 0 {
            utilClass.showAlertView(appNAME, "Please select Culture", self)
            
        }
        else {
            
            let paramDict = ["user_id"     :utilClass.getUserID(),
                             "email"     :emailTF.text!,
                             "first_name" : usernameTF.text!,
                             "lati": selectedLatitude,
                             "longi" : selectedLongitude,
                             "user_culture": "\((selectedCultureArr[0] as! NSDictionary).object(forKey: "id")!)"
                ] as NSDictionary
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KEditProfile, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                    }
                    else {
                        if self.pickedIm.length > 0{
                            self.uploadImage()

                        }
                        else {
                            let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Profile Updated!" as String, preferredStyle: .alert)
                            
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alertView.addAction(cancelAction)
                            self.present(alertView, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
        
    }
    
    
    func uploadImage() -> Void {
        
        let paramDict = ["id"     :utilClass.getUserID()] as NSDictionary
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        
        WebserviceClass.sharedInstance.UploadRequest(methodName: KUploadIMG, paramDictionary: paramDict, image_data: pickedIm, imageParameter: "file") { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                let codestr     = dict.object(forKey: "success") as! String
                
                if codestr .isEqual("0"){
                    
                    self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                }
                else {
                    let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Profile Updated!" as String, preferredStyle: .alert)
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertView.addAction(cancelAction)
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension EditProfileVC : UITextFieldDelegate{
    
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

extension EditProfileVC: GMSAutocompleteViewControllerDelegate {
    
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

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - ImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userIMG.image   = pickedImage
            pickedIm = UIImageJPEGRepresentation(pickedImage, 0.2)! as NSData
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension EditProfileVC: UITableViewDelegate, UITableViewDataSource {
    
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
