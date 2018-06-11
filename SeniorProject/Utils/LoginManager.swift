//
//  LoginManager.swift
//  SeniorProject
//
//  Created by Jin Young Jeong on 6/10/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation
import Alamofire

class LoginManager {
    static let loginManager = LoginManager()
    let appDefaults = UserDefaults.standard
    
    // User is attempting to login. Need to send login data and verify.
    // Authentication values are set accordingly
    // Don't really know how this should behave when username already exists... Will leave this up to you
    func userAuthenticationInitializer(userEmail: String, userPassword: String, completion: @escaping (Bool) -> Void) {
        // CODE
        completion(true)
    }
    
    
    // User is attempting to create a new user using the form data passed.
    // Connect to data base and add a new user to table.
    func userCreationInitializer(userEmail: String, userPassword: String, completion: @escaping (Bool) -> Void) {
        // CODE
        completion(true)
    }
}
