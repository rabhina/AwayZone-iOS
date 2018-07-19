//
//  DetailsVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 04/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import AVFoundation
import AVKit


class DetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: -
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var descriptionLB: UILabel!
    
    @IBOutlet weak var likeBTN: UIButton!
    @IBOutlet weak var ratingBTN: UIButton!
    @IBOutlet weak var adIMG: UIImageView!
    
    @IBOutlet weak var storiesLB: UILabel!
    @IBOutlet weak var commentsBTN: UIButton!
    @IBOutlet weak var reviewBTN: UIButton!
    
    //MARK: -
    @IBOutlet var myStoriesTV: UITableView!
    
    //MARK: -
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    var storiesDataArr     = NSArray()
    var imgURL  = String()
    //MARK: -
    
    var detailsDict = NSMutableDictionary()
    var iMGURL = String()
    
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myStoriesTV.register(UINib(nibName: "MyStoriesTVC", bundle: nil), forCellReuseIdentifier: "MyStoriesTVC")
        myStoriesTV.tableFooterView = UIView()
        
        showDataOnview()
    }
    
    func showDataOnview() -> Void {
        
        commentsBTN.setTitle("COMMENTS (\(detailsDict["comment"]!))", for: .normal)
        likeBTN.setTitle("\(detailsDict["likes"]!)", for: .normal)
        ratingBTN.setTitle("(\(detailsDict["rating"]!))", for: .normal)
        
        reviewBTN.setTitle("REVIEWS (\(detailsDict["review"]!))", for: .normal)
        
        titleLB.text         = "\(detailsDict["title"]!)"
        descriptionLB.text   = "\(detailsDict["description"]!)"
        
        adIMG.sd_setImage(with: URL(string: "\(iMGURL)\(detailsDict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        if let like     = detailsDict["user_likes"] as? Bool {
            if like {
                likeBTN.isSelected = true
            }
            else {
                likeBTN.isSelected = false
            }
        }
        
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getStories()

    }
    func getStories() -> Void {
        
        let paramDict = ["user_id"     :utilClass.getUserID(),
                         "ad_id" : "\(detailsDict["ad_id"]!)"
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KAdStoryList, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                if let image_url    = dict["image_url"] as? String {
                    self.imgURL  = image_url
                }
                if let storydata = dict["story"] as? NSArray {
                    self.storiesDataArr    = storydata
                    self.storiesLB.text  = "STORIES (\(self.storiesDataArr.count))"
                    self.myStoriesTV.reloadData()
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let subview = self.storyboard?.instantiateViewController(withIdentifier: "StoryDetailsVC") as! StoryDetailsVC
      //  self.addChildViewController(subview)
      //  self.view.addSubview((subview.view)!)
        
        subview.imageURL           = imgURL
        subview.detailsDict        = detailsDict
        subview.detailsStoryDict   = storiesDataArr[indexPath.row] as! NSMutableDictionary
        self.navigationController?.pushViewController(subview, animated: true)
        
        
//        subview.view.frame = CGRect(x: 0, y: subview.view.frame.size.width, width: (subview.view.frame.size.width), height: subview.view.frame.size.height)
//
//        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
//            subview.view.frame = CGRect(x: 0, y: 0, width: (subview.view.frame.size.width), height: (subview.view.frame.size.height))
//        }) { (finished : Bool) in
//        }
        
    }
    
    
    //MARK: -
    
    @IBAction func actionBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionAddStory(_ sender: Any) {
        let alertView: UIAlertController = UIAlertController(title: appNAME as String, message: "Upload Picture!!" as String, preferredStyle: .actionSheet)
        
        let galleryAction: UIAlertAction = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.image", "public.movie"]
            self.present(picker, animated: true, completion: nil)
        }
        
        alertView.addAction(galleryAction)
        
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take New Photo", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable (UIImagePickerControllerSourceType.camera) {
                
                let imag = UIImagePickerController()
                imag.delegate = self
                imag.sourceType = UIImagePickerControllerSourceType.camera
                imag.mediaTypes = ["public.image", "public.movie"]
                imag.allowsEditing = true
                
                self.present(imag, animated: true, completion: nil)
                
            }
        }
        alertView.addAction(cameraAction)
        
        let cnclAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .destructive) { action -> Void in
        }
        alertView.addAction(cnclAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    @IBAction func reviewAction(_ sender: Any) {
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "ReviewCommentVC") as! ReviewCommentVC
        view.title      = "REVIEWS"
        view.detailsDict    = detailsDict

        self.navigationController?.pushViewController(view, animated: true)
        
    }
    @IBAction func actionCommentsBtn(_ sender: Any) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "ReviewCommentVC") as! ReviewCommentVC
        view.title      = "COMMENTS"
        view.detailsDict    = detailsDict
        self.navigationController?.pushViewController(view, animated: true)
        
    }
    @IBAction func actionNavigation(_ sender: Any) {
        
        let lat     = "\(detailsDict["lati"]!)"
        let long    = "\(detailsDict["longi"]!)"
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(String(describing: lat)),\(String(describing: long))")! as URL)
            
        } else {
            UIApplication.shared.openURL(NSURL(string:
                "https://www.google.co.in/maps/dir/?saddr=&daddr=\(String(describing: lat)),\(String(describing: long))")! as URL)
        }
        
    }
    
    @IBAction func likeBtnAction(_ sender: Any) {
        
        self.likeBeenBookmark(dict: detailsDict, type: "like")
    }
    
    func likeBeenBookmark(dict : NSDictionary, type: String) -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID(),
                         "ad_id"   : "\(dict["ad_id"]!)",
            "type"   : type
            ] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KLikeBeenBookMark, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                let dict = responseDict as NSDictionary
                let codestr     = dict.object(forKey: "status") as! String
                
                if codestr .isEqual("0"){
                    
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    if self.likeBTN.isSelected {
                        
                        if let likk     = self.detailsDict["likes"] as? Int {
                            self.detailsDict.setValue(likk-1, forKey: "likes")

                        }
                        self.detailsDict.setValue(false, forKey: "user_likes")

                    }
                    else {
                        if let likk     = self.detailsDict["likes"] as? Int {
                            self.detailsDict.setValue(likk+1, forKey: "likes")
                            
                        }
                        self.detailsDict.setValue(true, forKey: "user_likes")

                    }
                    self.showDataOnview()
                }
            }
        })
    }
    
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
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}


extension DetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - ImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if((info["UIImagePickerControllerMediaType"] as! String) == "public.movie" ){
            if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
                
                let videoData = try? Data(contentsOf: pickedVideo)
                let view    = self.storyboard?.instantiateViewController(withIdentifier: "AddStoryVC") as! AddStoryVC
                view.detailsDict    = detailsDict
                view.selectedIMG    = videoData! as NSData
                view.imageOrVideo   = "video"
                self.navigationController?.pushViewController(view, animated: true)
                
            }
            self.dismiss(animated: true, completion: nil)

        }
        else{
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                
                let pickedIm = UIImageJPEGRepresentation(pickedImage, 0.2)! as NSData
                
                let view    = self.storyboard?.instantiateViewController(withIdentifier: "AddStoryVC") as! AddStoryVC
                view.detailsDict    = detailsDict
                view.selectedIMG    = pickedIm
                view.imageOrVideo   = "image"

                self.navigationController?.pushViewController(view, animated: true)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}




