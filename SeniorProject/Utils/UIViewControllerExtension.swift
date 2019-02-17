//
//  UIViewControllerExtensions.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/17/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import Foundation

extension UIViewController {
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
}
