//
//  ActivityLoadViewClass.swift
//  Exigosource
//
//  Created by Aravind kumar on 10/26/16.
//  Copyright © 2016 exigosource. All rights reserved.
//

import UIKit

class ActivityLoadViewClass
{
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!
    
    class var shared: ActivityLoadViewClass {
        struct Static {
            static let instance: ActivityLoadViewClass = ActivityLoadViewClass()
        }
        return Static.instance
    }
    
    init(){
        self.overlayView = UIView()
        
        self.activityIndicator = UIActivityIndicatorView()
        
        let rect = CGRect(x: 0, y: 0, width: 60, height: 60) // CGFloat, Double, Int
        
        overlayView.frame = rect;
        
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.layer.zPosition = 1
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let point = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        activityIndicator.center = point
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        overlayView.addSubview(activityIndicator)
    }
    
    open func showOverlay(_ view: UIView)
    {
        overlayView.center = view.center
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    open func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
