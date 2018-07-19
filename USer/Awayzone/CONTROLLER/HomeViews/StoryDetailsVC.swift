//
//  StoryDetailsVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 07/05/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit

class StoryDetailsVC: UIViewController {

    @IBOutlet var storyIMG: UIImageView!
    @IBOutlet var titleLB: UILabel!
    
    @IBOutlet var videoBtn: UIButton!
    //MARK: -
    
    var detailsStoryDict    = NSMutableDictionary()
    var detailsDict         = NSMutableDictionary()
    var imageURL            = String()
    
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLB.text    = detailsStoryDict["caption"] as? String ?? ""
        titleLB.numberOfLines   = 0
        
        let url = URL(string: "\(imageURL)\(detailsStoryDict["image"]!)")
        let path = url?.path
        let extensionstr = URL(fileURLWithPath: path ?? "").pathExtension
        if (extensionstr == "mp4") {
            videoBtn.isHidden   = false
            
            DispatchQueue.global().async {
                if let thumbnailImage = Utilities.sharedInstance.getThumbnailImage(forUrl: url!) {
                    DispatchQueue.main.async {
                        self.storyIMG.image = thumbnailImage
                    }
                }
            }
        }
        else {
            videoBtn.isHidden   = true
            storyIMG.sd_setImage(with: URL(string: "\(imageURL)\(detailsStoryDict["image"]!)")!, placeholderImage: UIImage(named: "App-Default"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
        }
       
    }
    //MARK: -
    
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
    
    @IBAction func actionClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionPlayvideo(_ sender: Any) {
        let url = URL(string: "\(imageURL)\(detailsStoryDict["image"]!)")
        
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
        // Dispose of any resources that can be recreated.
    }
    
}

extension StoryDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - ImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if((info["UIImagePickerControllerMediaType"] as! String) == "public.movie" ){
            if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
                
                let videoData = try? Data(contentsOf: pickedVideo)
                let view    = self.storyboard?.instantiateViewController(withIdentifier: "AddStoryVC") as! AddStoryVC
                view.detailsDict    = detailsDict
                view.imageOrVideo   = "video"
                view.selectedIMG    = videoData! as NSData
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


