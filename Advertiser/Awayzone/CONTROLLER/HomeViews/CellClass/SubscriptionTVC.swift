//
//  SubscriptionTVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 04/06/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class SubscriptionTVC: UITableViewCell {
    //MARK: -
    
    @IBOutlet var iconIMG: UIImageView!
    @IBOutlet var descLB: UILabel!
    @IBOutlet var titleLB: UILabel!
    @IBOutlet var priceLB: UILabel!    
    
    @IBOutlet var adsLB: UILabel!
    //MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
