//
//  AdsTVC.swift
//  Awayzone
//
//  Created by Pushpinder Kaur on 29/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class AdsTVC: UITableViewCell {

    
    @IBOutlet weak var adIMG: UIImageView!
    @IBOutlet weak var startDateLB: UILabel!
    
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var clicksLB: UILabel!
    @IBOutlet weak var impressionsLB: UILabel!

    @IBOutlet weak var pendingLB: UILabel!
    @IBOutlet weak var endDateLB: UILabel!
    
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
