//
//  ItemsTVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class ItemsTVC: UITableViewCell {

    @IBOutlet weak var itemIMG: UIImageView!
    @IBOutlet weak var boxIMG: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
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
