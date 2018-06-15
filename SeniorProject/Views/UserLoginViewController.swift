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
import PromiseKit

class UserLoginViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var userNameTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        //Check if username or password are empty
        if (userNameTextBox.text?.isEmpty)! || (passwordTextBox.text?.isEmpty)! {
            displayAlertToUser(userMessage: "Please fill in the missing information before proceeding")
            return
        }
        
        if let username = userNameTextBox.text, let password = passwordTextBox.text {
            firstly {
                 Api.shared.login(username: username, password: password)
            }.then { (result) -> Void in
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: result)
                UserDefaults.standard.set(encodedData, forKey: "loggedInUser")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                mainStore.dispatch(SetLoggedInUserAction(user: result))
                
                self.performSegue(withIdentifier: "moveToSpotifyLoginFromLogin", sender: self)
            }.catch { (error) in
                self.displayAlertToUser(userMessage: "Incorrect user login information")
                print(error)
            }
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
