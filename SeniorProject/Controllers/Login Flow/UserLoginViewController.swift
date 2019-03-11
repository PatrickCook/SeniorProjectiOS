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
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
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
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        // Check if username or password are empty
        guard let username = userNameTextBox.text,
              let password = passwordTextBox.text else {
            return
        }
        
        do {
            showLoadingAlert(uiView: self.view)
            try AuthController.signIn(username: username, password: password)
        } catch {
            dismissLoadingAlert(uiView: self.view)
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    @objc func handleAuthStateChange() {
        dismissLoadingAlert(uiView: self.view)
        
        if AuthController.isSignedIn {
           self.performSegue(withIdentifier: "moveToSpotifyLoginFromLogin", sender: self)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
