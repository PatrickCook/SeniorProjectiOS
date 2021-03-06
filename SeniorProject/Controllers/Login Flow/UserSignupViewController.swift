//
//  UserSignupViewController.swift
//  SeniorProject
//
//  Created by Jin Young Jeong on 6/7/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//
import ReSwift
import UIKit
import Foundation
import SpotifyLogin
import PromiseKit

class UserSignupViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var repeatpasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleAuthStateChange),
            name: .loginStatusChanged,
            object: nil
        )
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func newState(state: AppState) {
        enableLoadingIndicatorsAndErrorAlerts()
    }
    
    /*
     * Used for signing up. Checks that the username doesn't already exist in the system
     * and that both the passwords match and are valid.
     */
    @IBAction func createUserClicked(_ sender: Any) {
        
        guard let username = usernameInput.text,
            let password = passwordInput.text,
            let repeatPassword = repeatpasswordInput.text else {
                displayAlertToUser(userMessage: "Please fill in missing data")
                return
        }
        
        // Check all fields are filled out
        if username.isEmpty || password.isEmpty || repeatPassword.isEmpty {
            displayAlertToUser(userMessage: "Some fields are missing information")
            return
        }
        
        // Check that passwords match
        if password != repeatPassword{
            displayAlertToUser(userMessage: "Please make sure passwords match.")
            return
        }
        
        // Create new user and show loading icon
        do {
            try AuthController.createUser(username: username, password: password)
        } catch {
            displayAlertToUser(userMessage: "Error occured during registration.")
        }
    }
    
    @objc func handleAuthStateChange() {
        if AuthController.isSignedIn {
            self.performSegue(withIdentifier: "moveToSpotifyLoginFromLogin", sender: self)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
