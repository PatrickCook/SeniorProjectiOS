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
    var firstName: String
    var lastName: String
    var queues: [Queue]
    var songs: [Song]
    
    var description: String {
        return "User: { id: \(id), username: \(username), firstName: \(firstName), lastName: \(lastName)}"
    }
    
    public required init?(data: [String: Any]) {
        guard
            let id = data["id"] as? Int,
            let username = data["username"] as? String,
            let firstName = data["first_name"] as? String,
            let lastName = data["last_name"] as? String
        else {
            print("Error serializing User.")
            return nil
        }
        
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
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
