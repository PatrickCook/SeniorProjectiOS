//
//  UserSignupViewController.swift
//  SeniorProject
//
//  Created by Jin Young Jeong on 6/7/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit
import Foundation
import SpotifyLogin

class UserSignupViewController: UIViewController {
    let loginManager = LoginManager.loginManager

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var repeatpasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func createUserClicked(_ sender: Any) {
        if passwordInput.text != repeatpasswordInput.text {
            displayAlertToUser(userMessage: "Please make sure passwords match.")
            return
        }
        
        if (usernameInput.text?.isEmpty)! || (passwordInput.text?.isEmpty)! || (repeatpasswordInput.text?.isEmpty)! {
            displayAlertToUser(userMessage: "Some fields are missing information")
            return
        }
        
        if let username = usernameInput.text, let password = passwordInput.text {
            loginManager.userCreationInitializer(userEmail: username, userPassword: password, completion: { [weak self] response in
                if response {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self?.performSegue(withIdentifier: "moveToSpotifyLoginFromSignUp", sender: self)
                } else {
                    self?.displayAlertToUser(userMessage: "Error creating a new user")
                }
            })
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
