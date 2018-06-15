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
import PromiseKit

class UserSignupViewController: UIViewController {

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var repeatpasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     * Used for signing up. Checks that the username doesn't already exist in the system
     * and that both the passwords match and are valid.
     */
    @IBAction func createUserClicked(_ sender: Any) {
        
        // Check that passwords match
        if passwordInput.text != repeatpasswordInput.text {
            displayAlertToUser(userMessage: "Please make sure passwords match.")
            return
        }
        
        // Check all fields are filled out
        if (usernameInput.text?.isEmpty)! || (passwordInput.text?.isEmpty)! || (repeatpasswordInput.text?.isEmpty)! {
            displayAlertToUser(userMessage: "Some fields are missing information")
            return
        }
        
        // Verify with server and move to spotify authentication
        if let username = usernameInput.text, let password = passwordInput.text {
            firstly {
                Api.shared.createUser(username: username, password: password)
            }.then { (result) -> Void in
                mainStore.dispatch(SetLoggedInUserAction(user: result))
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.performSegue(withIdentifier: "moveToSpotifyLoginFromSignUp", sender: self)
            }.catch { (error) in
                self.displayAlertToUser(userMessage: "Error creating a new user")
                print(error)
            }
        }
    }
    
    /*
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
