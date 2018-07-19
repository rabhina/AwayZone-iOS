//
//  forgotPasswordVC.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class forgotPasswordVC: UIViewController {
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    @IBOutlet var emailTXT: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func resetAction(_ sender: Any) {
        
        if (!Utilities.sharedInstance.isValidEmail(testStr: emailTXT.text!)) {
            Utilities.sharedInstance.showAlertView(appNAME, "Please enter Valid Email", self)
        }
        else {
            let paramDict = ["email"        :emailTXT.text!
            ]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KForgot, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        let dict = responseDict as NSDictionary
                        let codestr     = dict.object(forKey: "status") as! String
                        
                        if codestr .isEqual("0"){
                            
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                        else {
                            let alertView: UIAlertController = UIAlertController(title:appNAME, message: "An email has been set to your entered email!" as String, preferredStyle: .alert)
                            
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
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
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
