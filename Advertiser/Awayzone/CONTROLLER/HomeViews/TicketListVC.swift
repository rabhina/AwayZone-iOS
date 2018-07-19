//
//  TicketListVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 14/06/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class TicketListVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    var allCommentArr   = NSMutableArray()

    @IBOutlet var ticketListTV: UITableView!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllComents()
    }
    
    //MARK: - GetComments
    
    func getAllComents() -> Void {
                
        let paramDict = ["advertiser_id" : utilClass.getUserID()
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KGetTicketList, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            
                self.allCommentArr   = NSMutableArray()
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        if let comment  = responseDict["ticket_data"] as? NSArray {
                            self.allCommentArr   = comment as! NSMutableArray
                            self.ticketListTV.reloadData()
                        }
                        else {
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                    }
                    
                }
            
        })
        
    }
    
    //MARK: -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCommentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVC", for: indexPath) as! CommentTVC
        let dict    = allCommentArr[indexPath.row] as! NSDictionary
        
        cell.dateLB.text    = dict["date"] as? String ?? ""
        cell.commentLB.text    = dict["description"] as? String ?? (dict["review"] as? String ?? "")
        
        cell.timeLB.text    = dict["time"] as? String ?? ""
        cell.nameLB.text    = "\(dict["title"] as? String ?? "") (\(dict["priority"] as? String ?? ""))" 
        
        cell.editBTN.tag  = indexPath.row
        cell.editBTN.addTarget(self,action:#selector(actionSelectBtn),
                               for:.touchUpInside)
        cell.editBTN.isHidden   = true
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight    = 60
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "ReviewCommentVC") as! ReviewCommentVC
        view.detailsDict    = allCommentArr[indexPath.row] as! NSMutableDictionary
        self.navigationController?.pushViewController(view, animated: true)
        
    }
    
    //MARK: -
    
    @IBAction func actionAddNEw(_ sender: Any) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "CreateTicketVC") as! CreateTicketVC
        self.navigationController?.pushViewController(view, animated: true)

    }
    @IBAction func actionBackBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - UICellBtnActions
    
    @objc func actionSelectBtn(sender: UIButton) -> Void {

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
