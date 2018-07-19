//
//  Utilities.swift
//  Challenge
//
//  Created by Ajay Kumar on 12/1/16.
//  Copyright © 2016 CQLsys. All rights reserved.
//

import UIKit
import AVFoundation

class Utilities: NSObject {

    static let sharedInstance = Utilities()
    static let appName  = "Shahena"
    
    func showAlertView(_ title : String, _ message : NSString, _ viewController : UIViewController) -> Void {
        
        let alertView: UIAlertController = UIAlertController(title: title, message: message as String, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            
        }
        alertView.addAction(cancelAction)
        viewController.present(alertView, animated: true, completion: nil)
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidatedPhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isValidatedPhone10(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func setUserID(_ userID : NSString) -> Void {
        
        let defaults = UserDefaults.standard
        defaults.set(userID, forKey: "UserID")
    }
    
    func getUserID() -> AnyObject {
        
        let defaults = UserDefaults.standard
        return (defaults.object(forKey: "UserID") as AnyObject)
        
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }

    
}
