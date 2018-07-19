//
//  initVC.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class initVC: UIViewController {
    
    @IBOutlet var signinBTN: UIButton!
    @IBOutlet var signupBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signinBTN.roundView()
        signupBTN.roundView()
        // Do any additional setup after loading the view.
    }
    
    /// button action
    
    @IBAction func signupAction(_ sender: Any) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC")
        self.present(view!, animated: true, completion: nil)
        
    }
    
    @IBAction func signinAction(_ sender: Any) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
        self.present(view!, animated: true, completion: nil)
    }
    
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
