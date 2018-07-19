//
//  ViewController.swift
//  Awayzone
//
//  Created by keshav kumar on 24/04/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*
         
         
         advertisers Api
         -------------------------------------------------------------------------------------------
         
         halfReg
         
         http://173.255.247.199/away_zone/advertisers/halfReg
         
         email
         reg_type
         notify_id
         password
         
         -------------------------------------------------------------------------------------------
         
         adverLogin
         
         http://173.255.247.199/away_zone/advertisers/adverLogin
         
         email
         password
         notify_id
         login_type
         
         -------------------------------------------------------------------------------------------
         
         fullReg
         
         http://173.255.247.199/away_zone/advertisers/fullReg
         
         culture
         interest
         full_name
         organization_name
         user_id
         contact_no
         lati
         longi
         email
         
         
         -------------------------------------------------------------------------------------------
         
         
         dashboard
         
         http://173.255.247.199/away_zone/advertisers/dashboard
         
         user_id
         type              -- day , month , year
         record_type   --   analytic , graph
         
         
         -------------------------------------------------------------------------------------------
         
         dashboardDay
         
         http://173.255.247.199/away_zone/advertisers/dashboardDay
         
         user_id
         
         
         
         -------------------------------------------------------------------------------------------
         
         getCommentReview
         
         http://173.255.247.199/away_zone/advertisers/getCommentReview
         
         user_id
         ad_id
         
         
         -------------------------------------------------------------------------------------------
         
         allStoryList
         
         http://173.255.247.199/away_zone/advertisers/allStoryList
         
         user_id
         ad_id
         
         -------------------------------------------------------------------------------------------
         
         
         adverProfile
         
         http://173.255.247.199/away_zone/advertisers/adverProfile
         
         user_id
         
         
         -------------------------------------------------------------------------------------------
         
         planList
         
         http://173.255.247.199/away_zone/advertisers/planList
         
         user_id
         
         -------------------------------------------------------------------------------------------
         
         changePassword
         
         http://173.255.247.199/away_zone/advertisers/changePassword
         
         user_id
         new_password
         old_password
         
         -------------------------------------------------------------------------------------------
         
         createAds
         
         http://173.255.247.199/away_zone/advertisers/createAds
         
         advertiser_id
         start_date
         end_date
         file
         title
         description
         user_subscription_id  ---- save internally
         lati              ---- save internally
         longi                 ---- save internally
         lat_long_city       ---- save internally
         
         -------------------------------------------------------------------------------------------
         
         myAds
         
         http://173.255.247.199/away_zone/advertisers/myAds
         
         user_id
         
         -------------------------------------------------------------------------------------------
         
         onOffAds
         
         http://173.255.247.199/away_zone/advertisers/onOffAds
         
         user_id
         id              -- means ad  id
         on_off
         -------------------------------------------------------------------------------------------
         
         
         checkLoginTime
         
         http://173.255.247.199/away_zone/advertisers/checkLoginTime
         
         user_id
         -------------------------------------------------------------------------------------------
         
         
         updateProfile
         
         http://173.255.247.199/away_zone/advertisers/updateProfile
         
         user_id
         culture
         interest
         email
         lati
         longi
         full_name
         organization_name
         contact_no
         alias_name
         user_description
         
         -------------------------------------------------------------------------------------------
         
         createChatTicket
         
         http://173.255.247.199/away_zone/advertisers/createChatTicket
         
         advertiser_id
         title
         description
         priority
         
         -------------------------------------------------------------------------------------------
         
         
         ticketList
         
         http://173.255.247.199/away_zone/advertisers/ticketList
         
         advertiser_id
         
         
         -------------------------------------------------------------------------------------------
         
         adverChat
         
         http://173.255.247.199/away_zone/advertisers/adverChat
         
         advertiser_id
         chat_ticket_id
         
         
         -------------------------------------------------------------------------------------------
         
         
         
         adverChatMessage
         
         http://173.255.247.199/away_zone/advertisers/adverChatMessage
         
         advertiser_id
         chat_ticket_id
         message
         -------------------------------------------------------------------------------------------
         
         
         checkReadMessage
         
         http://173.255.247.199/away_zone/advertisers/checkReadMessage
         
         advertiser_id
         chat_ticket_id
         
         
         -------------------------------------------------------------------------------------------
         
         openCloseTicket
         
         http://173.255.247.199/away_zone/advertisers/openCloseTicket
         
         advertiser_id
         chat_ticket_id
         
         
         
         -------------------------------------------------------------------------------------------
         
         saveAdverPlan
         
         http://173.255.247.199/away_zone/advertisers/saveAdverPlan
         
         advertiser_id
         subscription_id
         amount
         no_of_ads
         last_payment
         subscription_paypal_id
         
         
         
         -------------------------------------------------------------------------------------------
         
         
         http://173.255.247.199/away_zone/advertisers/defaultProfile
         
         user_id
         file
         
         -------------------------------------------------------------------------------------------
         
         
         http://173.255.247.199/away_zone/advertisers/upload_image
         
         Parameter
         file
         id
         
         Update Detail tab Image
         
         http://173.255.247.199/away_zone/advertisers/defaultProfile
         
         parameter
         
         file
         user_id

         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

