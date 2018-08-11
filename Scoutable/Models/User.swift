//
//  User.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import GoogleAPIClientForREST
import GoogleSignIn

class User: Codable {
    
    let uid: String
    let username: String
    var scoutTeam: String?
    var hasTeam: Bool = false
    var isLeader: Bool = false
    var roboticsTeamNumber: Int?
    var accessToken: String?
    
    
    private static var _current: User?
    
    static var current: User? {
        guard let currentUser = _current else {
            return nil
        }
        
        return currentUser
    }
    
    
    static func setCurrent(_ user: User){
        let guestData = NSKeyedArchiver.archivedData(withRootObject: false)
        UserDefaults.standard.set(guestData, forKey: "isGuestUser")
        _current = user
    }
    
    static func logOut(){
        GIDSignIn.sharedInstance()?.signOut()
        UserDefaults.standard.set(nil, forKey: "currentUser")
        UserDefaults.standard.set(nil, forKey: "isGuestUser")
        _current = nil
    }
    
    
    init(uid: String, username: String, accessToken: String){
        self.uid = uid
        self.username = username
        self.isLeader = false
        self.accessToken = accessToken
//        super.init()
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let accessToken = dict["accessToken"] as? String
            else { return nil }
        self.uid = snapshot.key
        self.username = username
        self.accessToken = accessToken
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
        if let teamNumber = dict["roboticsTeamNumber"] as? Int{
            self.roboticsTeamNumber = teamNumber
        }
//        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        self.accessToken = accessToken
    }
}

//extension User: NSCoding {
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(uid, forKey: "uid")
//        aCoder.encode(username, forKey: "username")
//    }
//
//}
