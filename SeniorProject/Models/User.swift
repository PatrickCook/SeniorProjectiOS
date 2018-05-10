//
//  UserModel.swift
//  SeniorProject
//
//  Created by Patrick Cook on 5/9/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import Foundation

class User {
    
    let id: Int
    let username: String
    let firstName: String
    let lastName: String
    let queues: [Queue]
    let songs: [Song]
    
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
}
