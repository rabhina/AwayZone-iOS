//
//  signUpVC.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import TwitterKit
import FacebookLogin
import FacebookCore


class signUpVC: UIViewController {
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet var confirmPasswordTXT: UITextField!
    @IBOutlet var passwordTXT: UITextField!
    @IBOutlet var emailTXT: UITextField!
    @IBOutlet var signUpBTN: UIButton!
    
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        signUpBTN.roundView()

    }
    
    //MARK: -
    @IBAction func show_PasswordAction(_ sender: Any) {
        if passwordTXT.isSecureTextEntry == false {
            passwordTXT.isSecureTextEntry = true
        }else {
            passwordTXT.isSecureTextEntry = false
        }
    }
    
    
    //MARK: - ButtonActions
    
    @IBAction func show_ConfirmPasswordAction(_ sender: Any) {
        if confirmPasswordTXT.isSecureTextEntry == false {
            confirmPasswordTXT.isSecureTextEntry = true
        }else {
            confirmPasswordTXT.isSecureTextEntry = false
        }
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if (!Utilities.sharedInstance.isValidEmail(testStr: emailTXT.text!)) {
            Utilities.sharedInstance.showAlertView(appNAME, "Please enter Valid Email", self)
        }
        else if (passwordTXT.text?.isEmpty)! {
            Utilities.sharedInstance.showAlertView(appNAME, "Please enter Password", self)
        }
        else if passwordTXT.text! != confirmPasswordTXT.text! {
            Utilities.sharedInstance.showAlertView(appNAME, "Password and Confirm Password must be same", self)
        }
        else {
            let paramDict = ["email"        :emailTXT.text!,
                             "password"     :passwordTXT.text!,
                             "reg_type"     :"email",
                             "notify_id"    :"1234"
            ]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KSignup, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr.isEqual("0"){
                        
                        objProfiledModel.email  = dict["email"] as? String ?? ""
                        
                        if let userID     = dict.object(forKey: "user_id") as? String {
                            objProfiledModel.id  = userID
                        }
                        else if let userID     = dict.object(forKey: "user_id") as? Int {
                            objProfiledModel.id  = "\(userID)"
                        }
                        
                        let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSetup")
                        self.view.window?.rootViewController = view

                    }
                    else if codestr.isEqual("5"){
                        self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                    }
                    else if codestr.isEqual("3"){
                        self.utilClass.showAlertView(appNAME, "Email already taken as Advertiser", self)
                    }
                    else if codestr.isEqual("1"){
                        self.utilClass.showAlertView(appNAME, "Email already Exists..", self)
                    }
                }
            })
        }
        
        
        
    }
    @IBAction func twitterAction(_ sender: Any) {
        
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                print("userID \(String(describing: session?.userID))");
                print("authToken \(String(describing: session?.authToken))");
                
                let userStr = session?.userName ?? ""
                let idStr   = session?.userID ?? ""
                
                
                let paramDict = ["email"        :"\(userStr)@twitter.com",
                    "password"     : "\(idStr)",
                    "reg_type"   :"twitter",
                    "notify_id"    :"1234ww"
                ]
                
                self.ActivityLoadViewClassObj.showOverlay(self.view)
                WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KSignup, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                    
                    DispatchQueue.main.async {
                        self.ActivityLoadViewClassObj.hideOverlayView()
                        
                        let dict = responseDict as NSDictionary
                        let codestr     = dict.object(forKey: "status") as! String
                        
                        if codestr .isEqual("0"){
                            
                            objProfiledModel.email  = dict["email"] as? String ?? ""
                            
                            if let userID     = dict.object(forKey: "user_id") as? String {
                                objProfiledModel.id  = userID
                            }
                            else if let userID     = dict.object(forKey: "user_id") as? Int {
                                objProfiledModel.id  = "\(userID)"
                            }
                            
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSetup")
                            self.view.window?.rootViewController = view
                            
                            
                        }
                        else if codestr.isEqual("5"){
                            self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                        }
                        else if codestr.isEqual("3"){
                            self.utilClass.showAlertView(appNAME, "Email already taken as Advertiser", self)
                        }
                        else if codestr.isEqual("1"){
                            self.utilClass.showAlertView(appNAME, "Email already Exists..", self)
                        }
                    }
                })
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    @IBAction func facebookAction(_ sender: Any) {
        
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( let grantedPermissions, let declinedPermissions, let accessToken):
                let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
                request.start { (response, result) in
                    switch result {
                    case .success(let value):
                        print(value.dictionaryValue)
                        
                        if let resDict  = (value.dictionaryValue! as? NSDictionary) {
                            self.facebookLoginResponse(dict: resDict)
                        }
                    case .failed(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    
    func facebookLoginResponse(dict: NSDictionary) -> Void {
        
        var emailStr    = dict["email"] as? String ?? ""
        let nameStr     = dict["name"] as? String ?? ""
        let idStr       = "\(dict["id"]!)"
        
        if emailStr == "" {
            emailStr    = "\(idStr)@facebook.com"
        }
        
        let paramDict = ["email"        :"\(emailStr)",
            "password"     : "\(idStr)",
            "reg_type"   :"facebook",
            "notify_id"    :"1234ww"
        ]
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KSignup, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                let codestr     = dict.object(forKey: "status") as! String
                
                if codestr .isEqual("0"){
                    
                    objProfiledModel.email  = dict["email"] as? String ?? ""
                    
                    if let userID     = dict.object(forKey: "user_id") as? String {
                        objProfiledModel.id  = userID
                    }
                    else if let userID     = dict.object(forKey: "user_id") as? Int {
                        objProfiledModel.id  = "\(userID)"
                    }
                    
                    let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSetup")
                    self.view.window?.rootViewController = view
                    
                }
                else if codestr.isEqual("5"){
                    self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again..", self)
                }
                else if codestr.isEqual("3"){
                    self.utilClass.showAlertView(appNAME, "Email already taken as Advertiser", self)
                }
                else if codestr.isEqual("1"){
                    self.utilClass.showAlertView(appNAME, "Email already Exists..", self)
                }
            }
        })
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
