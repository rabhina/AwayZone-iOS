//
//  SubscriptionVC.swift
//  Awayzone
//
//  Created by CHITRESH GOYAL on 04/06/18.
//  Copyright © 2018 keshav kumar. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PayPalPaymentDelegate {

    //MARK: -
    
    let ActivityLoadViewClassObj = ActivityLoadViewClass()
    let utilClass = Utilities.sharedInstance
    
    //MARK: -
    
    @IBOutlet var subscriptionTV: UITableView!
    var subscriptionsArr = NSMutableArray()
    var currentSubscArr  = NSMutableArray()

    var payPalConfig = PayPalConfiguration()
    var selectedIndex = Int()
    
    // MARK: -
    
    var environment:String = PayPalEnvironmentProduction {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getSubscriptionPlans()
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true
        payPalConfig.merchantName = appNAME  //Give your company name here.
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //This is the language in which your paypal sdk will be shown to users.
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //Here you can set the shipping address. You can choose either the address associated with PayPal account or different address. We'll use .both here.
        
        payPalConfig.payPalShippingAddressOption = .both;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
        
    }
    
    func getSubscriptionPlans() -> Void {
        
        let paramDict = ["user_id" : utilClass.getUserID()] as [String : Any]
        
        ActivityLoadViewClassObj.showOverlay(self.view)
        WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KPlanList, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
            
            DispatchQueue.main.async {
                self.ActivityLoadViewClassObj.hideOverlayView()
                
                if !isSuccess {
                    self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                }
                else {
                    
                    if let responseArr = responseDict["plan"] as? NSArray {
                        
                        self.currentSubscArr    = responseDict["user_plan"] as? NSMutableArray ?? NSMutableArray()
                        self.subscriptionsArr    = responseArr as! NSMutableArray
                        self.subscriptionTV.reloadData()
                    }
                    else {
                        self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                    }
                }
            }
        })
    }
    
    //MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return currentSubscArr.count
        }
        return subscriptionsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionTVC
        cell.selectionStyle = .none
        
        var dict    = NSDictionary()
        
        if indexPath.section == 0{
            dict    = currentSubscArr[indexPath.row] as! NSDictionary
        }
        else {
            dict    = subscriptionsArr[indexPath.row] as! NSDictionary
        }
        cell.titleLB.text   = "\(String(describing: dict["plan_name"]!))"
        cell.descLB.text    = "\(String(describing: dict["description"]!))"
                
        cell.iconIMG.image  = UIImage.init(named: "ICN_BACK\((indexPath.row+1)%3)")
        
        cell.adsLB.text     = "You can create \(dict["no_of_ads"]!) ads of this plan"
        cell.priceLB.text   = "$\(dict["amount"] ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight    = 160
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if currentSubscArr.count > 0 {
                return 60
            }
            else {
                return 0
            }
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section  == 0 {
            if currentSubscArr.count > 0{
                let customView = UIView(frame: CGRect(x: 5, y: 5, width: tableView.frame.size.width-10, height: 50))
                customView.layer.backgroundColor    = UIColor.init(red: 218/255.0, green: 70/255, blue: 0/255, alpha: 1).cgColor
                let label           = UILabel()
                label.frame         = CGRect(x: 0, y: 0, width: customView.frame.size.width, height: 50)
                label.textAlignment = NSTextAlignment.center
                
                let dict        = self.currentSubscArr[0] as! NSDictionary
                
                label.textColor = UIColor.white
                label.text      = "Current Plan Start date: \(dict["start_date"]!)"
                customView.addSubview(label)
                
                return customView
            }
            
            return UIView()
        }
        else {
            return UIView()
        }
        
       
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex   = indexPath.row
        let dict    = self.subscriptionsArr[self.selectedIndex] as! NSDictionary

        
        let item1 = PayPalItem(name: "\(dict["plan_name"] ?? "")", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(dict["amount"] ?? "")"), withCurrency: "USD", withSku: "\(dict["description"] ?? "")")

        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items) //This is the total price of all the items
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax) //This is the total price including shipping and tax
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "\(dict["plan_name"] ?? "")", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }

    }
    
    //MARK: - PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in

            if let responseD = completedPayment.confirmation["response"] as? NSDictionary {
                
                if (responseD.object(forKey: "state") as! String) == "approved" {
                    
                    let transID = responseD.object(forKey: "id") as? String ?? ""
                    let dict    = self.subscriptionsArr[self.selectedIndex] as! NSDictionary
                    
                    let paramDict = ["advertiser_id" : self.utilClass.getUserID(),
                                     "subscription_id" : "\(dict["id"] ?? "")",
                        "amount" : "\(dict["amount"] ?? "")",
                        "no_of_ads" : "\(dict["no_of_ads"] ?? "")",
                        "last_payment" : "\(dict["amount"] ?? "")",
                        "subscription_paypal_id" : transID] as [String : Any]
                    
                    self.ActivityLoadViewClassObj.showOverlay(self.view)
                    WebserviceClass.sharedInstance.apiCallWithParametersUsingPOST(methodName: KSubscribe, paramDictionary: paramDict as NSDictionary?, onCompletion: { (responseDict, isSuccess) in
                        
                        DispatchQueue.main.async {
                            self.ActivityLoadViewClassObj.hideOverlayView()
                            
                            if !isSuccess {
                                self.utilClass.showAlertView(appNAME, RESPONSE_ERROR as NSString, self)
                            }
                            else {
                                
                                if let statusstr = responseDict["status"] as? String {
                                    if statusstr == "0" {
                                        
                                        self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again!", self)
                                    }
                                    else
                                    {
                                        let alertView: UIAlertController = UIAlertController(title: appNAME, message: "Payment Succesfull!!" as String, preferredStyle: .alert)
                                        
                                        let cancelAction: UIAlertAction = UIAlertAction(title: "Done", style: .default) { action -> Void in
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        alertView.addAction(cancelAction)
                                        self.present(alertView, animated: true, completion: nil)
                                    }
                                }
                                else {
                                    self.utilClass.showAlertView(appNAME, "Error Occured.. Please Try Again!", self)
                                    
                                }
                            }
                        }
                    })
                }
                else {
                    self.utilClass.showAlertView(appNAME, "Payment Declined!", self)

                }
            }
            
        })
        
    }
    
    //MARK: -
    
    @IBAction func actionBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
