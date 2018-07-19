//
//  DetailsVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage

class DetailsVC: UIViewController {
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet var userIMG: UIImageView!
    @IBOutlet var descriptonTF: UITextField!
    @IBOutlet var alisaNameTF: UITextField!
    
    var pickedIm = NSData()
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alisaNameTF.text    = objEditModel.alias_name
        descriptonTF.text   = objEditModel.user_description
        
        if "\(objEditModel.image_url)\(objEditModel.defaultimage)" != "" {
            userIMG.sd_setImage(with: URL(string: "\(objEditModel.image_url)\(objEditModel.defaultimage)")!, placeholderImage: UIImage(named: "LOGO"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
        }
        
        
        
    }
    
    @IBAction func actionBackBtn(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProfileVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func actionUpdate(_ sender: Any) {
        
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
    
    @IBAction func actionChangePic(_ sender: Any) {
        
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
    
    //MARK: -
    
    func setUpViewForUPdate() -> Void {
        
        objEditModel.alias_name   = alisaNameTF.text!
        objEditModel.user_description              = descriptonTF.text!
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
    
    
    func uploadImage() -> Void {
        
        let paramDict = ["user_id"     :utilClass.getUserID()] as NSDictionary
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        
        WebserviceClass.sharedInstance.UploadRequest(methodName: KUPdateIMG, paramDictionary: paramDict, image_data: pickedIm, imageParameter: "file") { (responseDict, isSuccess) in
            
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
        
        setUpViewForUPdate()
        
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
extension DetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
