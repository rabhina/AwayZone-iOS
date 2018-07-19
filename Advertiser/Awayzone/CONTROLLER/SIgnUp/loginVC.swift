//
//  loginVC.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import TwitterKit
import FacebookCore
import FacebookLogin

class loginVC: UIViewController {
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet var signinBTN: UIButton!
    @IBOutlet var passwordTXT: UITextField!
    @IBOutlet var emailTXT: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // emailTXT.text       = "chinku@gmail.com"
        // passwordTXT.text    = "admin123"
        signinBTN.roundView()
    }
    
    @IBAction func showPasswordAction(_ sender: Any) {
        
        if passwordTXT.isSecureTextEntry == false {
            passwordTXT.isSecureTextEntry = true
        }else {
            passwordTXT.isSecureTextEntry = false
        }
        
    }
    @IBAction func forgotAction(_ sender: Any) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "forgotPasswordVC")
        self.present(view!, animated: true, completion: nil)
    }
    @IBAction func signinAction(_ sender: Any) {
        
        if (!Utilities.sharedInstance.isValidEmail(testStr: emailTXT.text!)) {
            Utilities.sharedInstance.showAlertView(appNAME, "Please enter Valid Email", self)
        }
        else if (passwordTXT.text?.isEmpty)! {
            Utilities.sharedInstance.showAlertView(appNAME, "Please enter Password", self)
        }
        else {
            let paramDict = ["email"        :emailTXT.text!,
                             "password"     :passwordTXT.text!,
                             "login_type"   :"email",
                             "notify_id"    :"1234"
            ]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KLogin, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        let dict = responseDict as NSDictionary
                        let codestr     = dict.object(forKey: "status") as! String
                        
                        if codestr .isEqual("0"){
                            
                            self.utilClass.showAlertView(appNAME, "Please enter Valid email and Password", self)
                        }
                        else {
                            self.loginSuccess(dict)
                        }
                    }
                }
            })
        }
    }
    
    
    //MARK: -
    
    func loginSuccess(_ bodyDict: NSDictionary) -> Void {
        
        if let userID     = bodyDict.object(forKey: "user_id") as? String {
            Utilities.sharedInstance.setUserID(userID as NSString)
            
        }
        else if let userID     = bodyDict.object(forKey: "user_id") as? Int {
            Utilities.sharedInstance.setUserID("\(userID)" as NSString)
            
        }
        
        let defaults    = UserDefaults.standard
        defaults.set(bodyDict.object(forKey: "email"),              forKey: "Email")
        defaults.set(bodyDict.object(forKey: "first_name"),         forKey: "Name")
        defaults.set("\(bodyDict.object(forKey: "full_reg")!)",     forKey: "full_reg")
        defaults.set(bodyDict.object(forKey: "image"),              forKey: "image")
        defaults.set(bodyDict.object(forKey: "image_url"),          forKey: "image_url")
        defaults.set("\(bodyDict.object(forKey: "user_ads")!)",     forKey: "user_ads")
        
        
        if bodyDict.object(forKey: "full_reg") as! Int == 0 {
            
            objProfiledModel.email  = bodyDict["email"] as? String ?? ""
            
            if let userID     = bodyDict.object(forKey: "user_id") as? String {
                objProfiledModel.id  = userID
            }
            else if let userID     = bodyDict.object(forKey: "user_id") as? Int {
                objProfiledModel.id  = "\(userID)"
            }
            
            
            let view = self.storyboard?.instantiateViewController(withIdentifier: "ProfileSetup")
            self.view.window?.rootViewController = view
        }
        else {
            
            objProfiledModel = ProfileSetupModel()
            objProfiledModel.setupProfileUSer(dict: bodyDict)

            objEditModel = EditProfileModel()
            objEditModel.setupEditProfileUSer(dict: bodyDict)

            let view = self.storyboard?.instantiateViewController(withIdentifier: "HomeViews")
            self.view.window?.rootViewController = view
        }
    }
    
    //MARK: -
    
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
                        else {
                            self.utilClass.showAlertView(appNAME, "Error Occured.. Try again Later!", self)
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
        //let nameStr     = dict["name"] as? String ?? ""
        let idStr       = "\(dict["id"]!)"
        
        if emailStr == "" {
            emailStr    = "\(idStr)@facebook.com"
        }
        
        let paramDict = ["email"        :"\(emailStr)",
            "password"     : "\(idStr)",
            "login_type"   :"facebook",
            "notify_id"    :"1234"
        ]
        
        self.ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KLogin, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, "Error Occured.. Try Again Later!!", self)
                    }
                    else {
                        self.loginSuccess(dict)
                    }
                }
            }
        })
        
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
                    "login_type"   :"twitter",
                    "notify_id"    :"1234"
                ]
                
                self.ActivityLoadViewClassObj.showOverlay(self.view)
                WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KLogin, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                    
                    DispatchQueue.main.async {
                        self.ActivityLoadViewClassObj.hideOverlayView()
                        
                        if !isSuccess {
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                        else {
                            
                            let dict = responseDict as NSDictionary
                            let codestr     = dict.object(forKey: "status") as! String
                            
                            if codestr .isEqual("0"){
                                
                                self.utilClass.showAlertView(appNAME, "Error Occured.. Try Again Later!!", self)
                            }
                            else {
                                self.loginSuccess(dict)
                            }
                        }
                    }
                })
                
                
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        
    }
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
