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
    
    
    //MARK: -
    @IBOutlet var reviewCommentTV: UITableView!
    @IBOutlet var titleLB: UILabel!
    
    @IBOutlet var enterreviewTxV: UITextView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var userIMG: UIImageView!
    //MARK: -
    
    var detailsDict = NSMutableDictionary()
    var allCommentArr   = NSMutableArray()
    var commentTypeEditOrAdd    = "add"
    var commentID               = ""
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLB.text    = self.title
        reviewCommentTV.keyboardDismissMode = .onDrag

        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().enable = false

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllComents()
        if "\(objProfiledModel.image_url)\(objProfiledModel.image)" != "" {
            userIMG.sd_setImage(with: URL(string: "\(objProfiledModel.image_url)\(objProfiledModel.image)")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            
        }
    }
    
    //MARK: - GetComments
    
    func getAllComents() -> Void {
        
        var typeStr = String()
        if self.title == "COMMENTS" {
            typeStr = "comment"
        }
        else {
            typeStr = "review"
        }
        
        let paramDict = ["user_id" : utilClass.getUserID(),
                         "ad_id"   : "\(detailsDict["ad_id"]!)",
            "type"   : typeStr
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KGetComments, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            self.allCommentArr   = NSMutableArray()
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if let comment  = responseDict["comment"] as? NSArray {
                    self.allCommentArr   = comment as! NSMutableArray
                    self.reviewCommentTV.reloadData()
                }
                else {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
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
        cell.commentLB.text    = dict["comment"] as? String ?? (dict["review"] as? String ?? "")

        cell.timeLB.text    = dict["time"] as? String ?? ""
        cell.nameLB.text    = dict["first_name"] as? String ?? ""
        
        cell.editBTN.tag  = indexPath.row
        cell.editBTN.addTarget(self,action:#selector(actionSelectBtn),
                                 for:.touchUpInside)
        if self.title == "COMMENTS" {
            cell.editBTN.isHidden   = false
        }
        else {
            cell.editBTN.isHidden   = true
        }
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
    
    @IBAction func actionProfileBTn(_ sender: Any) {
        
        
    }
    @IBAction func actionBackBtn(_ sender: Any) {
        IQKeyboardManager.sharedManager().enable            = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSend(_ sender: Any) {
        
        /*
         http://173.255.247.199/away_zone/users/commentReview
         
         text    --  for review and comment
         
         type   -----   comment or review
         comment_type   add , edit , delete
         ad_id
         user_id
         comment_id     when edit or delete comment or review
         */
        
        if enterreviewTxV.text!.replacingOccurrences(of: " ", with: "") == "" {
            utilClass.showAlertView(appNAME, "Please add review!", self)
        }
        else {
            var typeStr = String()
            if self.title == "COMMENTS" {
                typeStr = "comment"
            }
            else {
                typeStr = "review"
            }
            
            let paramDict = ["user_id" : utilClass.getUserID(),
                             "ad_id"   : "\(detailsDict["ad_id"]!)",
                "type"   : typeStr,
                "text"   : enterreviewTxV.text!,
                "comment_type" :    commentTypeEditOrAdd,
                "comment_id" : commentID
                ] as [String : Any]
            
            ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KAddComment, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.commentTypeEditOrAdd    = "add"
                    self.commentID               = ""
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
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
            })
            
        }
    }
    
    //MARK: - UICellBtnActions
    
    @objc func actionSelectBtn(sender: UIButton) -> Void {
        
        let alertController = UIAlertController(title: appNAME, message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Edit", style: .default){ action -> Void in

            let dict = self.allCommentArr[sender.tag] as! NSDictionary
            self.commentID   = "\(dict["comment_id"]!)"
            self.commentTypeEditOrAdd    = "edit"

            self.enterreviewTxV.text     = dict["comment"] as? String ?? (dict["review"] as? String ?? "")
            self.enterreviewTxV.becomeFirstResponder()
        }
        alertController.addAction(defaultAction)
        
        let action1 = UIAlertAction(title: "Delete", style: .default) { action -> Void in
            
            let dict = self.allCommentArr[sender.tag] as! NSDictionary
            
            var typeStr = String()
            if self.title == "COMMENTS" {
                typeStr = "comment"
            }
            else {
                typeStr = "review"
            }
            
            let paramDict = ["user_id" : self.utilClass.getUserID(),
                             "ad_id"   : "\(self.detailsDict["ad_id"]!)",
                "type"   : typeStr,
                "comment_type" :    "delete",
                "comment_id"  :"\(dict["comment_id"]!)",
                "text"   : dict["comment"] as? String ?? (dict["review"] as? String ?? "")

                ] as [String : Any]
            
            
            
            self.ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KAddComment, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        self.getAllComents()
                    }
                    
                }
            })
            
        }
        alertController.addAction(action1)
        
        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cnclAction)
        
        present(alertController, animated: true, completion: nil)
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
