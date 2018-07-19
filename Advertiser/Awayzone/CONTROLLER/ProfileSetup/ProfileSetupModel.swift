//
//  ProfileSetupModel.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 03/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

var objProfiledModel = ProfileSetupModel()

class ProfileSetupModel: NSObject {
    
    var id      = String()
    var email   = String()
    var lati    = String()
    var longi   = String()
    var userIMG = UIImage()

    var first_name       = String()
    var contactNo        = String()
    var organisationName  = String()
    
    
    //Not in USe
    var user_culture     = String()
    var culture_id       = String()
    var interest         = NSArray()
    var culture          = NSArray()
    
    var image_url   = String()
    var image       = String()
    
    var lat_long_city   = String()
    var beenHere        = String()
    var bookmark        = String()
    var story           = String()
    var no_of_ads       = String()

    var user_description      = String()
    var alias_name            = String()
    var defaultimage          = String()

    func setupProfileUSer(dict : NSDictionary) -> Void {
        
        email       = dict["email"] as? String ?? ""
        culture     = dict["culture_data"] as? NSArray ?? NSArray()
        first_name  = dict["first_name"] as? String ?? ""
        defaultimage       = dict["default_profile_image"] as? String ?? ""
        image       = dict["image"] as? String ?? ""
        image_url   = dict["image_url"] as? String ?? ""
        
        interest    = dict["interest"] as? NSArray ?? NSArray()
        contactNo    = dict["contact_no"] as? String ?? ""
        organisationName    = dict["organization_name"] as? String ?? ""
        no_of_ads   = "\(dict["ads"] as? Int ?? 0)"
        lati        = "\(dict["lati"] as? Double ?? 0.00)"
        longi       = "\(dict["longi"] as? Double ?? 0.00)"

        user_culture    = dict["user_culture"] as? String ?? ""
        lat_long_city   = dict["lat_long_city"] as? String ?? ""
        
        alias_name       = dict["alias_name"] as? String ?? ""
        user_description = dict["user_description"] as? String ?? ""
        
        
        let defaults    = UserDefaults.standard
        defaults.set(dict.object(forKey: "image"),              forKey: "image")
        defaults.set(dict.object(forKey: "image_url"),          forKey: "image_url")

    }
}
