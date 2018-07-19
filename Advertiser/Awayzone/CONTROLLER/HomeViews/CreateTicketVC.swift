//
//  CreateTicketVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 14/06/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class CreateTicketVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    @IBOutlet var priorityTF: UITextField!
    @IBOutlet var titleTF: UITextField!
    @IBOutlet var descriptionTF: UITextField!
    
    private let myValues: NSArray = ["low","medium","High"]
    
    //MARK: -
    
    private var myUIPicker: UIPickerView!
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUIPicker = UIPickerView()
        
        myUIPicker.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 200)
        myUIPicker.delegate = self
        myUIPicker.dataSource = self
        
        priorityTF.inputView    = myUIPicker
        
        //self.view.addSubview(myUIPicker)
    }
    
    //MARK: -
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSend(_ sender: Any) {
        
        /*
         advertiser_id
         title
         description
         priority
         */
        if (titleTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Please Enter Title", self)
        }
        else if (descriptionTF.text?.isEmpty)! {
            utilClass.showAlertView(appNAME, "Enter Description", self)
        }
        else if (priorityTF.text?.isEmpty)!{
            utilClass.showAlertView(appNAME, "Please Select Priority", self)
        }
        else {
            let paramDict = ["advertiser_id" : utilClass.getUserID(),
                             "description" : descriptionTF.text!,
                             "title" : titleTF.text!,
                             "priority" : priorityTF.text!
                ] as [String : Any]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KCreateTicket, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        let dict = responseDict as NSDictionary
                        let codestr     = dict.object(forKey: "status") as! String
                        
                        if codestr .isEqual("0"){
                            
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                        else {
                            let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Ticket Created!" as String, preferredStyle: .alert)
                            
                            let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alertView.addAction(cancelAction)
                            self.present(alertView, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    
    //MARK: -
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myValues[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        priorityTF.text = myValues[row] as? String ?? ""
        print("value: \(myValues[row])")
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
