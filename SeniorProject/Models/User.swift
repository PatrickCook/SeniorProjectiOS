//
//  UserModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/9/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class User: Hashable, Equatable {
    
    var id: Int
    var username: String
    var role: String
    var queues: [Queue]
    var songs: [SpotifySong]
    
    var description: String {
        return "User: { id: \(id), username: \(username)}"
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
        self.queues = []
        self.songs = []
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        get {
            return id.hashValue << 15 + username.hashValue
        }
    }
}
