//
//  UserLoginViewController.swift
//  SeniorProject
//
//  Created by Jin Young Jeong on 6/7/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import Foundation
import SpotifyLogin

class UserLoginViewController: UIViewController {
    lazy var loginManager = LoginManager.loginManager
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var userNameTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        //Check if username or password are empty
        if (userNameTextBox.text?.isEmpty)! || (passwordTextBox.text?.isEmpty)! {
            print("HERE PLEASE")
            displayAlertToUser(userMessage: "Please fill in the missing information before proceeding")
            return
        }
        
        if let username = userNameTextBox.text, let password = passwordTextBox.text {
            loginManager.userAuthenticationInitializer(userEmail: username, userPassword: password, completion: { [weak self] response in
                if response {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self?.performSegue(withIdentifier: "moveToSpotifyLoginFromLogin", sender: self)
                } else {
                    self?.displayAlertToUser(userMessage: "Incorrect user login information")
                }
            })
        } else {
            print("Error: Login button pressed but user input is invalid")
        }
    }
    
    /*
     * DISPLAY ALERT TO USER
     * Used to display an alert to the user. User has option to press ok
     */
    func displayAlertToUser(userMessage: String) {
        // Create and Allert
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil)
        
        // Add action to the alert
        myAlert.addAction(okAction)
        
        // Present the alert to the user
        self.present(myAlert, animated: true, completion: nil)
    }
}
