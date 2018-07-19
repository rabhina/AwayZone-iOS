//
//  MyStoriesVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 05/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit


class MyStoriesVC: UIViewController,UITableViewDelegate, UITableViewDataSource {

    //MARK: -
    @IBOutlet var MyStoriesTV: UITableView!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    var storiesDataArr     = NSArray()
    var imgURL  = String()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        MyStoriesTV.register(UINib(nibName: "MyStoriesTVC", bundle: nil), forCellReuseIdentifier: "MyStoriesTVC")
        MyStoriesTV.tableFooterView = UIView()
    }
    
    //MARK: -
    override func viewWillAppear(_ animated: Bool) {
        
        self.getStories()
    }
    
    func getStories() -> Void {
        
        let paramDict = ["user_id"     :utilClass.getUserID()
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KStoryList, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                if let image_url    = dict["image_url"] as? String {
                    self.imgURL  = image_url
                }
                if let storydata = dict["story"] as? NSArray {
                    self.storiesDataArr    = storydata
                    
                    self.MyStoriesTV.reloadData()
                }
                else {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
            }
        })
    }
    //MARK: - UITableViewDelegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return storiesDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "MyStoriesTVC", for: indexPath) as! MyStoriesTVC
        
        cell.selectionStyle = .none
        cell.storyIMG.layer.cornerRadius    = 5
        cell.storyIMG.clipsToBounds          = true
        
        
        let dict    = storiesDataArr[indexPath.row] as! NSDictionary
        cell.descLB.text    = dict["caption"] as? String ?? ""
        cell.descLB.numberOfLines   = 0
        
        let url = URL(string: "\(imgURL)\(dict["image"]!)")
        let path = url?.path
        let extensionstr = URL(fileURLWithPath: path ?? "").pathExtension
        if (extensionstr == "mp4") {
            cell.videoBtn.isHidden   = false
            cell.videoBtn.addTarget(self,action:#selector(actionPlayvideo),
                                     for:.touchUpInside)
            DispatchQueue.global().async {
                if let thumbnailImage = Utilities.sharedInstance.getThumbnailImage(forUrl: url!) {
                    DispatchQueue.main.async {
                        cell.storyIMG.image = thumbnailImage
                    }
                }
            }
        }
        else {
            cell.videoBtn.isHidden   = true

            cell.storyIMG.sd_setImage(with: URL(string: "\(imgURL)\(dict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
        }
        cell.videoBtn.tag  = indexPath.row

        cell.updateBTN.tag  = indexPath.row
        cell.updateBTN.addTarget(self,action:#selector(actionSelectBtn),
                                 for:.touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: - UICellBtnActions
    
    
    @objc func actionPlayvideo(sender: UIButton) -> Void {
        
        let dict    = storiesDataArr[sender.tag] as! NSDictionary

        let url = URL(string: "\(imgURL)\(dict["image"]!)")
        
        let player = AVPlayer(url: url!)
        let vc = AVPlayerViewController()
        vc.player = player
        
        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
    @objc func actionSelectBtn(sender: UIButton) -> Void {
        
        let alertController = UIAlertController(title: appNAME, message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Edit", style: .default){ action -> Void in
            
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "AddStoryVC") as! AddStoryVC
            view.storyDetailsDict   = self.storiesDataArr[sender.tag] as! NSMutableDictionary
            view.title  = "Update"
            self.navigationController?.pushViewController(view, animated: true)
            
        }
        alertController.addAction(defaultAction)
        
        let action1 = UIAlertAction(title: "Delete", style: .default) { action -> Void in
            
            let detailsDict = self.storiesDataArr[sender.tag] as! NSDictionary
            let paramDict = ["user_id" : self.utilClass.getUserID(),
                             "ad_id"   : "\(detailsDict["ad_id"]!)",
                "type"   : "delete",
                "caption": "\(detailsDict["caption"]!)",
                "story_id": "\(detailsDict["story_id"]!)",
                ] as [String : Any]
            
            self.ActivityLoadViewClassObj.showOverlay(self.view)
            WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KUpdateStory, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
                
                DispatchQueue.main.async {
                    self.ActivityLoadViewClassObj.hideOverlayView()
                    
                    
                    let dict = responseDict as NSDictionary
                    let codestr     = dict.object(forKey: "status") as! String
                    
                    if codestr .isEqual("0"){
                        
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                    else {
                        self.getStories()
                    }
                    
                }
            })
            
        }
        alertController.addAction(action1)
        
        let cnclAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cnclAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - ButtonActions
    @IBAction func backBtnAction(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
