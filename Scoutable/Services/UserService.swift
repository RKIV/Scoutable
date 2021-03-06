//
//  UserService.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase
import GoogleSignIn

struct UserService{
    //Create a user on the databse
    static func create(_ gidUser: GIDGoogleUser, username: String, accessToken: String, completion: @escaping (User?) -> Void){
        //Make the dict to be added to the JSON
        let userAttrs = ["username" : username, "hasTeam" : false, "isLeader" : false, "accessToken" : accessToken] as [String : Any]
        //Make reference to server side user
        let ref = Database.database().reference().child("users").child(gidUser.userID)
        //At reference add the dict
        ref.setValue(userAttrs){ (error, ref) in
            if let error = error{
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            //Return the user to the caller
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
            
        }
    }
    //Read a user on the database
    static func show(forUID uid: String, completion: @escaping (User?) -> Void){
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                completion(nil)
                
                return
            }
            completion(user)
        }) { (error) in
            print("Error incorrect uid: \(error.localizedDescription)")
        }
    }
    
    static func setRoboticsTeamNumber(as teamNumber: Int){
        let ref = Database.database().reference().child("users").child((User.current?.uid)!).child("roboticsTeamNumber")
        ref.setValue(teamNumber) { (error, _) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
        User.current?.roboticsTeamNumber = teamNumber
    }
}
