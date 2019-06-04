//
//  UIViewControllerExtensions.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/10/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//
import UIKit
import Foundation

extension UIViewController {
    
    func showLoadingAlert(uiView: UIView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.tag = -1
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: container.frame.size.width / 2,
                                     y: container.frame.size.height / 3);
        loadingView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                                y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    func dismissLoadingAlert(uiView: UIView) {
        for view in uiView.subviews {
            if (view.tag == -1) {
                view.removeFromSuperview()
            }
        }
    }
    
    func showErrorAlert(error: String) {
        let alertController = UIAlertController(title: "Network Error", message: error, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default) { (action) in
            mainStore.dispatch(DismissErrorAction())
        }
        
        alertController.addAction(actionOk)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func enableLoadingIndicatorsAndErrorAlerts() {
        if mainStore.state.showLoadingIndicator {
            showLoadingAlert(uiView: self.view)
        } else {
            dismissLoadingAlert(uiView: self.view)
        }
        
        if let errMsg = mainStore.state.errorMessage {
            showErrorAlert(error: errMsg)
        }
    }
    
    /*
     * DISPLAY ALERT TO USER
     * Used to display an alert to the user. User has option to press ok
     */
    func displayAlertToUser(userMessage: String) {
        print("Display Alert to User")
        // Create and Allert
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:nil)
        
        // Add action to the alert
        myAlert.addAction(okAction)
        
        // Present the alert to the user
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func displayAlertToUserWithHandler(title: String, userMessage: String, handler: @escaping ((UIAlertAction) -> Void)) {
        print("Display Alert to User")
        // Create and Allert
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: handler)
        
        // Add action to the alert
        myAlert.addAction(okAction)
        // Present the alert to the user
        self.present(myAlert, animated: true, completion: nil)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
