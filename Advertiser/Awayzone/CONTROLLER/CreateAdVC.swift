//
//  CreateAdVC.swift
//  Awayzone
//
//  Created by Pushpinder Kaur on 29/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class CreateAdVC: UIViewController {
    
    //MARK: -
    @IBOutlet weak var imgHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var adIMG: UIImageView!
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var enddateTF: UITextField!
    
    //MARK: - Variables
    
    var startDateStr    = String()
    var endDateStr    = String()

    var pickedIm = NSData()
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgHeightConst.constant = 0
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        startDateTF.inputView = datePickerView
        datePickerView.minimumDate  = Date()
        datePickerView.addTarget(self, action: #selector(CreateAdVC.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        
        let datePickerView1:UIDatePicker = UIDatePicker()
        datePickerView1.datePickerMode = UIDatePickerMode.date
        enddateTF.inputView = datePickerView1
        datePickerView1.minimumDate  = Date()

        datePickerView1.addTarget(self, action: #selector(CreateAdVC.datePickerValueChanged1), for: UIControlEvents.valueChanged)
    }
    
    //MARK: -
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        startDateTF.text = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        startDateStr = dateFormatter.string(from: sender.date)

        
    }
    
    @objc func datePickerValueChanged1(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        enddateTF.text = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        endDateStr = dateFormatter.string(from: sender.date)

    }
    
    override func viewDidLayoutSubviews() {
        startDateTF.layer.cornerRadius  = startDateTF.frame.size.height/2.0
        startDateTF.clipsToBounds       = true
        
        enddateTF.layer.cornerRadius  = enddateTF.frame.size.height/2.0
        enddateTF.clipsToBounds       = true
    }
    
    //MARK: - UIButtonActions
    
    @IBAction func actionUpload(_ sender: Any) {
        
        if (titleTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter Title", self)
        }
        else if (descriptionTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter Description", self)
        }
        else if pickedIm.length <= 0 {
            utilClass.showAlertView(appNAME, "Please Upload Image", self)
        }
        else if (startDateTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please select Start Date", self)
        }
        else if (enddateTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please select End Date", self)
        }
        else if (checkTimeStamp(date:startDateTF.text!, endDate: enddateTF.text!) == true) {
            utilClass.showAlertView(appNAME, "Please select end date later than start date", self)
        }
        else  {
            let paramDict = ["advertiser_id"     :utilClass.getUserID(),
                             "title"             :titleTF.text!,
                             "description"       :descriptionTF.text!
                ] as NSDictionary
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            
            WebserviceClass.sharedInstance.UploadRequest(methodName: KCreateAds, paramDictionary: paramDict, image_data: pickedIm, imageParameter: "file") { (responseDict, isSuccess) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        if let codestr     = responseDict.object(forKey: "success") as? Int {
                            if "\(codestr)" .isEqual("0"){
                                self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                            }
                            else if "\(codestr)" .isEqual("2"){
                                self.utilClass.showAlertView(appNAME, "No Ads Left", self)
                            }
                            else if "\(codestr)" .isEqual("3"){
                                self.utilClass.showAlertView(appNAME, "Plan Expired!", self)
                            }
                            else if "\(codestr)" .isEqual("4"){
                                self.utilClass.showAlertView(appNAME, "Plan Inactive!", self)
                            }
                                
                            else {
                                
                                if let adID = responseDict["ad_id"] as? Int {
                                    self.updateAddDateTime(ad_id: adID)
                                }
                                else {
                                    self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                                }
                            }
                        }
                        else if let codestr     = responseDict.object(forKey: "status") as? String {
                            if "\(codestr)" .isEqual("0"){
                                self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                            }
                            else if "\(codestr)" .isEqual("2"){
                                self.utilClass.showAlertView(appNAME, "No Ads Left", self)
                            }
                            else if "\(codestr)" .isEqual("3"){
                                self.utilClass.showAlertView(appNAME, "Plan Expired!", self)
                            }
                            else if "\(codestr)" .isEqual("4"){
                                self.utilClass.showAlertView(appNAME, "Plan Inactive!", self)
                            }
                            else if "\(codestr)" .isEqual("7"){
                                self.utilClass.showAlertView(appNAME, "Please buy Subscription Plan! !", self)
                            }
                                
                            else {
                                
                                if let adID = responseDict["ad_id"] as? Int {
                                    self.updateAddDateTime(ad_id: adID)
                                }
                                else {
                                    self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                                }
                            }
                        }
                        else {
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                    }
                }
            }
        }
    }
    
    func checkTimeStamp(date: String! , endDate : String!) -> Bool {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let datecomponents = dateFormatter.date(from: date)
        let now = dateFormatter.date(from: endDate)
        
        
        if (datecomponents! >= now!) {
            return true
        } else {
            return false
        }
    }
    
    func updateAddDateTime(ad_id: Int) {
        let paramDict = ["ad_id"     :"\(ad_id)",
            "start_date"        :startDateStr,
            "end_date"          :endDateStr
            ] as NSDictionary
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KCreateAddate, paramDictionary: paramDict) { (responseDict, isSuccess) in
            
            print(responseDict)
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    if let codestr     = dict.object(forKey: "status") as? String {
                        if codestr .isEqual("0"){
                            self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                        }
                        else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        self.utilClass.showAlertView(appNAME, "Error Occured", self)
                    }
                }
            }
        }
    }
    
    @IBAction func actionImageUpload(_ sender: Any) {
        
        let alertView: UIAlertController = UIAlertController(title: "" as String, message: "Upload Ad Image!!" as String, preferredStyle: .actionSheet)
        
        let galleryAction: UIAlertAction = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        }
        
        alertView.addAction(galleryAction)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take New Photo", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable (UIImagePickerControllerSourceType.camera) {
                
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
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
}

extension CreateAdVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - ImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imgHeightConst.constant = 160
            adIMG.image   = pickedImage
            pickedIm = UIImageJPEGRepresentation(pickedImage, 0.4)! as NSData
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}
