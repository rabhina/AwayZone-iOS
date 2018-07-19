//
//  SplashVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 05/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    //MARK: -
    
    override func viewDidAppear(_ animated: Bool) {
        
        let utilClass = Utilities.sharedInstance
        
        if let user = utilClass.getUserID() as? String {
            if user == "" {
                let view    = self.storyboard?.instantiateViewController(withIdentifier: "initVC")
                self.view.window?.rootViewController    = view
            }
            else {
                let view    = self.storyboard?.instantiateViewController(withIdentifier: "HomeViews")
                self.view.window?.rootViewController    = view
            }
        }
        else {
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "initVC")
            self.view.window?.rootViewController    = view
        }
    }
    
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
