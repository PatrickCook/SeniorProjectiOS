//
//  Auth.swift
//  SeniorProject
//
//  Created by Patrick Cook on 2/28/19.
//  Copyright © 2019 Patrick Cook. All rights reserved.
//

import Foundation
import CryptoSwift

final class AuthController {
    static let shared: AuthController = AuthController()
    static let serviceName = "QueueItService"
    static let MIN_PASSWORD_LENGTH = 0
    
    private init () {}
    
    
    static var isSignedIn: Bool {
        guard let currentUser = Settings.currentUser else {
            return false
        }
        
        do {
            let password = try KeychainPasswordItem(service: serviceName, account: currentUser.username).readPassword()
            return password.count > 0
        } catch {
            return false
        }
    }
    
    class func passwordHash(from username: String, password: String) -> String {
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(username).\(salt)".sha256()
    }
    
    class func signIn(username: String, password: String) throws {
        let finalHash = passwordHash(from: username, password: password)
        try KeychainPasswordItem(service: serviceName, account: username).savePassword(finalHash)
        // Check against server and move onto spotify authentication
        Api.shared.login(username: username, password: finalHash)
            .then { (result) -> Void in
                mainStore.dispatch(SetLoggedInUserAction(user: result))
                Settings.currentUser = result

                NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
            }.catch { (error) in
                // TODO: Implement error display with reswift
                print("error during logging in")
            }
    }
    
    class func createUser(username: String, password: String) throws {
        let finalHash = passwordHash(from: username, password: password)
        Api.shared.createUser(username: username, password: finalHash)
            .catch { (error) in
                print(error)
        }
    }
    
    class func signOut() throws {
        guard let currentUser = Settings.currentUser else {
            return
        }
        
        try KeychainPasswordItem(service: serviceName, account: currentUser.username).deleteItem()
        
        Settings.currentUser = nil
        NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
    }
    
}

extension Notification.Name {
    
    static let loginStatusChanged = Notification.Name("com.pcook.QueueIt.auth.changed")
    
}
