//
//  UserModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/9/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    var id: Int
    var username: String
    var role: String
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeInteger(forKey: "id")
        self.username = decoder.decodeObject(forKey: "username") as! String
        self.role = decoder.decodeObject(forKey: "role") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(username, forKey: "username")
        coder.encode(role, forKey: "role")
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let username = data["username"] as? String,
            let role = data["role"] as? String
        else {
            print("Error serializing User.")
            return nil
        }
        
        self.id = id
        self.username = username
        self.role = role
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    override var hashValue: Int {
        get {
            return id.hashValue << 15 + username.hashValue
        }
    }
}
