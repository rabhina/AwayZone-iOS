//
//  ProfileVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 29/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit
import SDWebImage


class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var profileTV: UITableView!
    
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var beenHereBTN: UIButton!
    @IBOutlet weak var bookMarkBTN: UIButton!
    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: - Variables
    
    var profileArr = ["Edit Profile", "Change Password", "Rate App", "Refer a Friend", "My Cultures", "My Interests", "My Stories"]
    var imageArr    = ["ICN_EDIT", "ICN_PASSWORD", "ICN_RATE", "ICN_REFER", "ICN_CULTURE", "ICN_INTEREST", "ICN_STORIES"]
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getDashboardData()
    }
    
    func getDashboardData() -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID()]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KuserProfile, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()

                objProfiledModel = ProfileSetupModel()
                objProfiledModel.setupProfileUSer(dict: responseDict)
                self.showProfile()
            }
        })
    }
    
    func showProfile() -> Void {
        
        nameLB.text = objProfiledModel.first_name
        bookMarkBTN.setTitle("BOOKMARKS(\(objProfiledModel.bookmark))", for: .normal)
        beenHereBTN.setTitle("BEEN HERE(\(objProfiledModel.beenHere))", for: .normal)

        userIMG.sd_setImage(with: URL(string: "\(objProfiledModel.image_url)\(objProfiledModel.image)")!, placeholderImage: UIImage(named: "DEFAULT_USER"),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        profileTV.reloadData()
    }
    
    //MARK: -
    override func viewDidAppear(_ animated: Bool) {
        userIMG.layer.cornerRadius  = userIMG.frame.size.width/2
        userIMG.clipsToBounds       = true
    }
    
    
    //MARK: - TableviewDelegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath)
        cell.selectionStyle = .none
        
        
        let itemIMG = cell.contentView.viewWithTag(1) as! UIImageView
        let nameLB  =  cell.contentView.viewWithTag(2) as! UILabel

        let countLB  =  cell.contentView.viewWithTag(3) as! UILabel

        
        itemIMG.image   = UIImage.init(named: imageArr[indexPath.row])
        nameLB.text     = profileArr[indexPath.row]
        
        countLB.isHidden    = true
        countLB.layer.cornerRadius  = countLB.frame.size.height/2.0
        countLB.clipsToBounds       = true
        
        if indexPath.row > 3 {
            countLB.isHidden    = false
            
            if indexPath.row == 4 {
                countLB.text    = "\(objProfiledModel.culture.count)"
            }
            else if indexPath.row == 5 {
                countLB.text    = "\(objProfiledModel.interest.count)"
            }
            else if indexPath.row == 6 {
                countLB.text    = "\(objProfiledModel.story)"
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            self.navigationController?.pushViewController(view, animated: true)
            break
            
        case 1:
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "UpdatePasswordVC") as! UpdatePasswordVC
            self.navigationController?.pushViewController(view, animated: true)
            break
        case 3:
            self.showActivitySheet()
            break
        case 4:
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "MyCulturesVC") as! MyCulturesVC
            self.navigationController?.pushViewController(view, animated: true)
            break
        case 5:
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "MyInterestVC") as! MyInterestVC
            self.navigationController?.pushViewController(view, animated: true)
            break
        case 6:
            let view    = self.storyboard?.instantiateViewController(withIdentifier: "MyStoriesVC") as! MyStoriesVC
            self.navigationController?.pushViewController(view, animated: true)
            break
        default:
            break
        }
    }
    
    //MARK: - UIbuttonActions
    
    @IBAction func actionBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionBookmark(_ sender: Any) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        view.title  = "bookmark"
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @IBAction func actionBeenHere(_ sender: Any) {
        
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksVC") as! BookmarksVC
        view.title  = "been"
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    
    @IBAction func actionLogoutBtn(_ sender: Any) {
        
        utilClass.setUserID("")
        let view    = self.storyboard?.instantiateViewController(withIdentifier: "initVC")
        self.view.window?.rootViewController    = view
    }
    //MARK: - Custom Methods
    
    
    func showActivitySheet()  {
        
        let text = "This is some text that I want to share."
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
