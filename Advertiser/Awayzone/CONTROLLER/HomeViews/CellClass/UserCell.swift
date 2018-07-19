//
//  UserCell.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 07/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet var userIMG: UIImageView!
    
    @IBOutlet var selectIMG: UIImageView!
    @IBOutlet var nameLB: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
