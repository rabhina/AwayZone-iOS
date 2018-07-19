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
    
    func setupProfileUSer(dict : NSDictionary) -> Void {
        
        email       = dict["email"] as? String ?? ""
        culture     = dict["culture_data"] as? NSArray ?? NSArray()
        first_name  = dict["first_name"] as? String ?? ""
        image       = dict["image"] as? String ?? ""
        image_url   = dict["image_url"] as? String ?? ""
        interest    = dict["interest"] as? NSArray ?? NSArray()
        
        lati        = "\(dict["lati"] as? Double ?? 0.00)"
        longi       = "\(dict["longi"] as? Double ?? 0.00)"

        user_culture    = dict["user_culture"] as? String ?? ""
        lat_long_city   = dict["lat_long_city"] as? String ?? ""
        
        if let been     = dict["been_here"] as? Int {
            beenHere    = "\(been)"
        }
        if let been     = dict["been_here"] as? String {
            beenHere    = been
        }
        
        if let book     = dict["bookmark"] as? Int {
            bookmark    = "\(book)"
        }
        if let book     = dict["bookmark"] as? String {
            bookmark    = book
        }
        
        if let cul     = dict["culture_id"] as? Int {
            culture_id    = "\(cul)"
        }
        if let cul     = dict["culture_id"] as? String {
            culture_id    = cul
        }
        
        if let str     = dict["story"] as? Int {
            story    = "\(str)"
        }
        if let str     = dict["story"] as? String {
            story    = str
        }
    }
}
