//
//  ScoutTeamService.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct ScoutTeamServices{
    static func makeTeamRequest(to scoutTeam: String){
        let ref = Database.database().reference()
        ref.child("scoutTeams").child(scoutTeam).child("requests").child((User.current?.uid)!).setValue(false) { (error, _) in
            if let error = error{
                print(error.localizedDescription)
            }
            ref.child("users").child((User.current?.uid)!).child("requests").child(scoutTeam).setValue(false) { (error, _) in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func create(_ scoutTeam: String){
        User.current?.hasTeam = true
        User.current?.isLeader = true
        User.current?.scoutTeam = scoutTeam
        let ref = Database.database().reference()
        let leaderAttrs = ["leader" : true]
        ref.child("scoutTeams").child(scoutTeam).child("users").child((User.current?.uid)!).setValue(leaderAttrs) { (error, _) in
            if let error = error{
                print(error.localizedDescription)
            }
            let userReference = ref.child("users").child((User.current?.uid)!)
            let userAttrs = ["scoutTeam" : scoutTeam, "hasTeam" : true, "isLeader" : true] as [String : Any]
            userReference.updateChildValues(userAttrs)
        }
    }
    
    static func getRequests(complete: @escaping ([String]?, _ error: String?) -> ()) {
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("requests")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : Any?]{
                    var uidArray = [String]()
                    for element in dict{
                        uidArray.append(element.key)
                    }
                    complete(uidArray, nil)
                } else {
                    complete(nil, "Snapshot not of correct type")
                }
            }
        } else {
            complete(nil, "User doesn't have team or is not leader")
        }
    }
    
    static func approveRequest(forUserUID uid: String, complete: @escaping (_ error: String?) -> ()){
        guard (User.current?.hasTeam)! && (User.current?.isLeader)! else { return complete("User doesn't have team or is not leader") }
        let scoutTeam = User.current?.scoutTeam
        let userRef = Database.database().reference().child("users").child(uid).child("requests").child(scoutTeam!)
        let scoutTeamRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("requests").child(uid)
        userRef.setValue(true)
        Database.database().reference().child("scoutTeams").child(scoutTeam!).child("users").child(uid).child("isLeader").setValue(false)
        scoutTeamRef.removeValue()
        complete(nil)
    }
    
    static func getUsers(complete: @escaping ([String], _ error: String?) -> ()){
        guard (User.current?.hasTeam)! && (User.current?.isLeader)! else { return complete([], "User doesn't have team or is not leader") }
        let scoutTeam = User.current?.scoutTeam
        let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("users")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any]{
                var uidArray = [String]()
                for item in dict{
                    uidArray.append(item.key)
                }
                complete(uidArray, nil)
            } else {
                complete([], "No users")
            }
        }
    }
    
    static func getRequestsSent(forUser uid: String, complete: @escaping ([String : Bool]) -> ()){
        let ref = Database.database().reference().child("users").child(uid).child("requests")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String : Bool]{
                let requests = value
                complete(requests)
            } else {
                complete([:])
                
            }

        }
    }
    
    static func leaveScoutTeam(forUser uid: String){
        Database.database().reference().child("users").child(uid).child("scoutTeam").removeValue()
        User.current?.scoutTeam = nil
    }
    
    static func joinScoutTeam(forUser uid: String, scoutTeam: String){
        Database.database().reference().child("users").child(uid).child("scoutTeam").setValue(scoutTeam)
        User.current?.scoutTeam = scoutTeam
    }
    
}

