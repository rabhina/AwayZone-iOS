//
//  BeenHereVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 30/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class BeenHereVC: UIViewController {
    //MARK: - IBoutlets

    @IBOutlet weak var beenHereTV: UITableView!
    
    @IBOutlet weak var searchBarTF: UISearchBar!
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: -
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func actionFilterBTn(_ sender: Any) {
    
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "SORT BY MAGIC", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        let action1 = UIAlertAction(title: "SORT BY POPULARITY", style: .default, handler: nil)
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "SORT BY RATING", style: .default, handler: nil)
        alertController.addAction(action2)
        
        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cnclAction)
        
        present(alertController, animated: true, completion: nil)
    }
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
