//
//  TeamService.swift
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
        ref.child("scoutTeams").child(scoutTeam).child("users").child((User.current?.uid)!).child("accepted").setValue(false) { (error, _) in
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
        let leaderAttrs = ["accepted" : true, "leader" : true]
        ref.child("scoutTeams").child(scoutTeam).child("users").child((User.current?.uid)!).setValue(leaderAttrs) { (error, _) in
            if let error = error{
                print(error.localizedDescription)
            }
            let userReference = ref.child("users").child((User.current?.uid)!)
            let userAttrs = ["scoutTeam" : scoutTeam, "hasTeam" : true, "isLeader" : true] as [String : Any]
            userReference.updateChildValues(userAttrs)
        }
    }
}

