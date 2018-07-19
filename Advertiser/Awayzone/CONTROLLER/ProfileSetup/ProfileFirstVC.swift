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
    @IBOutlet weak var organisationTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var userIMG: UIImageView!

    @IBOutlet var contactNoTF: UITextField!
    @IBOutlet var personTF: UITextField!
    //MARK: -
    var selectedLatitude     = ""
    var selectedLongitude    = ""
    
    var pickedIm = NSData()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.text    =   objProfiledModel.email
        emailTF.isUserInteractionEnabled    = false        
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
        else if (organisationTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter organisation name", self)
        }
        else if pickedIm.length == 0{
            utilClass.showAlertView(appNAME, "Please select User Image", self)
        }
        else if (contactNoTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please enter Contact Number", self)
        }
        
        else {
            objProfiledModel.lati   = selectedLatitude
            objProfiledModel.longi  = selectedLongitude
            objProfiledModel.organisationName = organisationTF.text!
            objProfiledModel.userIMG    = userIMG.image!
            objProfiledModel.contactNo = contactNoTF.text!
            objProfiledModel.first_name = personTF.text!
            
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


