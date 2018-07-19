//
//  viewClass.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import Foundation
import UIKit
extension UIButton{
    
    func roundView(){
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds      = true
    }
    
}

