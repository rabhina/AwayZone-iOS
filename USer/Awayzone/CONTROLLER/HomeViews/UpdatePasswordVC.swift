//
//  UpdatePasswordVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class UpdatePasswordVC: UIViewController {

    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -

    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var confirmPswdTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /*
         
         http://173.255.247.199/away_zone/users/changePassword
         
         user_id
         new_password
         old_password
         */

    }
    
    
    //MARK: -
    @IBAction func actionBackBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionUpdatePassword(_ sender: Any) {
        
        if (oldPasswordTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME,"Enter Old Password!" , self)
        }
        else if (newPasswordTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME,"Enter New Password!" , self)

        }
        else if confirmPswdTF.text! != newPasswordTF.text {
            utilClass.showAlertView(appNAME,"Confirm Password should be same as New Password" , self)

            
        }
        else {
            
            let paramDict = ["user_id" : utilClass.getUserID(),
                             "new_password"   : newPasswordTF.text!,
                "old_password"   : oldPasswordTF.text!
                ] as [String : Any]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KUpdatePassword, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Password Updated Succesfully!" as String, preferredStyle: .alert)
                        
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
