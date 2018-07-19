//
//  CommentTVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 06/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class CommentTVC: UITableViewCell {

    @IBOutlet var userIMG: UIImageView!
    @IBOutlet var nameLB: UILabel!
    
    @IBOutlet var timeLB: UILabel!
    @IBOutlet var dateLB: UILabel!
    
    @IBOutlet var commentLB: UILabel!
    
    @IBOutlet var editBTN: UIButton!
    
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
