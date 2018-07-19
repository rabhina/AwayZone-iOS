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
    
    @IBOutlet var personInchargeTF: UITextField!
    @IBOutlet var mobileNoTF: UITextField!
    
    //MARK: -
    var selectedLatitude     = ""
    var selectedLongitude    = ""
    
    var pickedIm = NSData()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.text    = objEditModel.email
        usernameTF.text = objEditModel.organisationName
        locationTF.text = objEditModel.lat_long_city
        mobileNoTF.text = objEditModel.contactNo
        personInchargeTF.text = objEditModel.first_name
        
        var latt    = objEditModel.lati
        if latt == "" {
            latt = "0.00"
        }
        var long    = objEditModel.longi
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
        
        if "\(objEditModel.image_url)\(objEditModel.image)" != "" {
            userIMG.sd_setImage(with: URL(string: "\(objEditModel.image_url)\(objEditModel.image)")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
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
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProfileVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    
    @IBAction func updateBtnAction(_ sender: Any) {
        
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
                            
                            self.actionBackButton(self)
                        }
                        alertView.addAction(cancelAction)
                        self.present(alertView, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    
    func uploadImage() -> Void {
        
        let paramDict = ["id"     :utilClass.getUserID()] as NSDictionary
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        
        WebserviceClass.sharedInstance.UploadRequest(methodName: KUpdateUserIMG, paramDictionary: paramDict, image_data: pickedIm, imageParameter: "file") { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    
                    if let codestr     = dict.object(forKey: "success") as? Int {
                        if "\(codestr)".isEqual("0"){
                            
                            self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                        }
                        else {
                            let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Profile Image Updated!" as String, preferredStyle: .alert)
                            
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alertView.addAction(cancelAction)
                            self.present(alertView, animated: true, completion: nil)
                        }
                    }
                    else if let codeStr = dict.object(forKey: "success") as? String {
                        if "\(codeStr)".isEqual("0"){
                            
                            self.utilClass.showAlertView(appNAME, "Error Occured .. Please Try again!", self)
                        }
                        else {
                            let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Profile Image Updated!" as String, preferredStyle: .alert)
                            
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
        
    }
    
    
    //MARK: - TopBarButtonActions
    
    func setUpViewForUPdate() -> Void {
        
        objEditModel.organisationName   = usernameTF.text!
        objEditModel.email              = emailTF.text!
        objEditModel.contactNo          = mobileNoTF.text!
        objEditModel.first_name         = personInchargeTF.text!
        
    }
    
    
    @IBAction func actionInterestBTn(_ sender: Any) {
        
        setUpViewForUPdate()
        
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
        
    }
    @IBAction func actionDetailsBtn(_ sender: Any) {
        
        setUpViewForUPdate()
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
        setUpViewForUPdate()
        
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
        
        objEditModel.lati   = selectedLatitude
        objEditModel.longi  = selectedLongitude
        objEditModel.lat_long_city  = "\(place.formattedAddress!)"
        
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
            
            uploadImage()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
