//
//  MyStoriesTVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 05/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class MyStoriesTVC: UITableViewCell {

    @IBOutlet var storyIMG: UIImageView!
    @IBOutlet var descLB: UILabel!
    @IBOutlet var updateBTN: UIButton!
    @IBOutlet var videoBtn: UIButton!
    
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
