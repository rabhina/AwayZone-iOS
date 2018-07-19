//
//  ReviewCommentVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 06/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class ReviewCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    @IBOutlet var chatListTV: UITableView!
    @IBOutlet var closeBTN: UIButton!
    
    //MARK: -
    
    @IBOutlet var enterreviewTxV: UITextView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var bottomView: UIView!
    //MARK: -
    
    var detailsDict = NSMutableDictionary()
    var allCommentArr   = NSMutableArray()

    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTV.keyboardDismissMode = .onDrag

        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = false

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllComents()
    }
    
    //MARK: - GetComments
    
    func getAllComents() -> Void {

        let paramDict = ["advertiser_id" : utilClass.getUserID(),
                         "chat_ticket_id"   : "\(detailsDict["ticket_id"]!)"
            ] as [String : Any]

        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KAdvChat, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in

            self.allCommentArr   = NSMutableArray()
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    
                    if let comment  = responseDict["chat_arr"] as? NSArray {
                        
                        if let chatDict   = (comment[0] as? NSDictionary) {
                            
                            if chatDict["ticket_status"] as! Int == 1 {
                                self.closeBTN.setTitle("CLOSE", for: .normal)
                                self.bottomView.isHidden    = false
                                self.bottomConstraint.constant   = 0
                            }
                            else {
                                self.closeBTN.setTitle("RE-OPEN", for: .normal)
                                self.bottomView.isHidden    = true
                                self.bottomConstraint.constant   = -50
                                
                            }
                            if let chatArr  = chatDict["chat_data"] as? NSArray {
                                self.allCommentArr   = chatArr as! NSMutableArray
                            }
                        }
                        self.chatListTV.reloadData()
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

        cell.dateLB.text    = dict["chat_date"] as? String ?? ""
        cell.commentLB.text    = dict["message"] as? String ?? ""

        cell.timeLB.text    = dict["chat_time"] as? String ?? ""
        
        var chatUSerID = dict["advertiser_id"] as? Int ?? 0
        
        if "\(chatUSerID)" == utilClass.getUserID() as! String {
            cell.nameLB.text    =  "You"
        }
        
        cell.editBTN.tag  = indexPath.row
       // cell.editBTN.addTarget(self,action:#selector(actionSelectBtn),
        //                         for:.touchUpInside)
        //if self.title == "COMMENTS" {
        //    cell.editBTN.isHidden   = false
       // }
      //  else {
            cell.editBTN.isHidden   = true
      //  }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight    = 60
        return UITableViewAutomaticDimension
    }
    //MARK: - KeyboardMethods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            bottomConstraint.constant = keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
        
    }
    
    //MARK: -
    
    @IBAction func actionCloseBtn(_ sender: Any) {
        
        let paramDict = ["advertiser_id" : utilClass.getUserID(),
                         "chat_ticket_id"   : "\(detailsDict["ticket_id"]!)"
            ] as [String : Any]
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KticketOPENCLose, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("1"){
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                }
            }
        })
    }
    @IBAction func actionBackBtn(_ sender: Any) {
        IQKeyboardManager.sharedManager().enable            = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSend(_ sender: Any) {
        
        if enterreviewTxV.text!.replacingOccurrences(of: " ", with: "") == "" {
            utilClass.showAlertView(appNAME, "Please add Message!", self)
        }
        else {

            let paramDict = ["advertiser_id" : utilClass.getUserID(),
                             "chat_ticket_id"   : "\(detailsDict["ticket_id"]!)",
                             "message"   : enterreviewTxV.text!
                ] as [String : Any]

            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KSendMEsage, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in

                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()

                    if !isSuccess {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        
                        let dict = responseDict as NSDictionary
                        let codestr     = dict.object(forKey: "status") as! String
                        
                        if codestr .isEqual("1"){
                            
                            self.enterreviewTxV.text = ""
                            
                            self.getAllComents()
                        }
                        else {
                            self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                        }
                    }
                }
            })

        }
    }
    
    //MARK: - UICellBtnActions
    
    @objc func actionSelectBtn(sender: UIButton) -> Void {
        
//        let alertController = UIAlertController(title: appNAME, message: "", preferredStyle: .actionSheet)
//        
//        let defaultAction = UIAlertAction(title: "Edit", style: .default){ action -> Void in
//
//            let dict = self.allCommentArr[sender.tag] as! NSDictionary
//            self.commentID   = "\(dict["comment_id"]!)"
//            self.commentTypeEditOrAdd    = "edit"
//
//            self.enterreviewTxV.text     = dict["comment"] as? String ?? (dict["review"] as? String ?? "")
//            self.enterreviewTxV.becomeFirstResponder()
//        }
//        alertController.addAction(defaultAction)
//        
//        let action1 = UIAlertAction(title: "Delete", style: .default) { action -> Void in
//            
//            let dict = self.allCommentArr[sender.tag] as! NSDictionary
//            
//            var typeStr = String()
//            if self.title == "COMMENTS" {
//                typeStr = "comment"
//            }
//            else {
//                typeStr = "review"
//            }
//            
//            let paramDict = ["user_id" : self.utilClass.getUserID(),
//                             "ad_id"   : "\(self.detailsDict["ad_id"]!)",
//                "type"   : typeStr,
//                "comment_type" :    "delete",
//                "comment_id"  :"\(dict["comment_id"]!)",
//                "text"   : dict["comment"] as? String ?? (dict["review"] as? String ?? "")
//
//                ] as [String : Any]
//            
//            
//            
//            self.ActivityLoadViewClassObj.showOverlay(self.view)
//            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KAddComment, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
//                
//                DispatchQueue.main.async {
//                    self.ActivityLoadViewClassObj.hideOverlayView()
//                    
//                    
//                    let dict = responseDict as NSDictionary
//                    let codestr     = dict.object(forKey: "status") as! String
//                    
//                    if codestr .isEqual("0"){
//                        
//                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
//                    }
//                    else {
//                        self.getAllComents()
//                    }
//                    
//                }
//            })
//            
//        }
//        alertController.addAction(action1)
//        
//        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
//        alertController.addAction(cnclAction)
//        
//        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: -
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
