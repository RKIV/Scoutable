//
//  User.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    let uid: String
    let username: String
    var scoutTeam: String?
    var hasTeam: Bool = false
    var isLeader: Bool = false
    var teamNumber: Int?
    
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    static var currentUserExists: Bool {
        if _current == nil {
            return false
        }
        return true
    }
    
    
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false){
        if writeToUserDefaults{
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: "currentUser")
            let guestData = NSKeyedArchiver.archivedData(withRootObject: false)
            UserDefaults.standard.set(guestData, forKey: "isGuestUser")
        }
        _current = user
    }
    
    static func logOut(){
        UserDefaults.standard.set(nil, forKey: "currentUser")
        UserDefaults.standard.set(nil, forKey: "isGuestUser")
        _current = nil
    }
    
    
    init(uid: String, username: String){
        self.uid = uid
        self.username = username
        self.isLeader = false
        super.init()
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        if let scoutTeam = dict["scoutTeam"] as? String {
            self.scoutTeam = scoutTeam
            hasTeam = true
            if let isLeader = dict["isLeader"] as? Bool {
                self.isLeader = isLeader
            } else {
                return nil
            }
        } else {
            hasTeam = false
        }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(username, forKey: "username")
    }
    
}
