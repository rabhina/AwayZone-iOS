//
//  EditProfileModel.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

var objEditModel = EditProfileModel()

class EditProfileModel: NSObject {
    
    var lati    = String()
    var longi   = String()
    var lat_long_city   = String()
    var email   = String()
    var first_name       = String()
    var contactNo        = String()
    var organisationName  = String()
    
    var image        = String()
    var image_url    = String()
    
    var interest         = NSArray()
    var culture          = NSArray()
 
    var userIMG      = UIImage()
    var user_description      = String()
    var alias_name            = String()
    var defaultimage          = String()
    
    func setupEditProfileUSer(dict : NSDictionary) -> Void {
        
        email       = dict["email"] as? String ?? ""
     //   culture     = dict["culture_data"] as? NSArray ?? NSArray()
        first_name  = dict["first_name"] as? String ?? ""
        defaultimage       = dict["default_profile_image"] as? String ?? ""
        image       = dict["image"] as? String ?? ""

        image_url   = dict["image_url"] as? String ?? ""
        
    //    interest    = dict["interest"] as? NSArray ?? NSArray()
        contactNo    = dict["contact_no"] as? String ?? ""
        organisationName    = dict["organization_name"] as? String ?? ""

        lati        = "\(dict["lati"] as? Double ?? 0.00)"
        longi       = "\(dict["longi"] as? Double ?? 0.00)"
        
        lat_long_city   = dict["lat_long_city"] as? String ?? ""
        
        alias_name       = dict["alias_name"] as? String ?? ""
        user_description = dict["user_description"] as? String ?? ""

        
      
        let defaults    = UserDefaults.standard
        defaults.set(dict.object(forKey: "image"),              forKey: "image")
        defaults.set(dict.object(forKey: "image_url"),          forKey: "image_url")

        
        
    }
    
}
