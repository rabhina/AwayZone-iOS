//
//  CategoriesTVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class CategoriesTVC: UITableViewCell {

    //MARK: -
    
    @IBOutlet weak var dropDownIMG: UIImageView!
    @IBOutlet weak var categoryNameLB: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
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
