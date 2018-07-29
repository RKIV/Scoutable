//
//  ScoutDataService.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct ScoutDataService{
    
    static func addStaticTemplateCell(_ fieldName: String, fieldType : FieldTypes, year: Int, complete: @escaping (_ cellID: String?, _ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static").childByAutoId()
            ref.updateChildValues(["name" : fieldName, "type" : fieldType.rawValue])
            complete(ref.key, nil)
        } else {
            complete(nil, "User Has No Team or Isn't Leader")
        }
    }
    
    
    static func removeStaticTemplateCell(cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    ref.child(cellID).removeValue()
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func editStaticTemplateCell(from oldFieldName: String,to newFieldName: String, cellID: String, fieldType: FieldTypes, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    ref.child(cellID).child(oldFieldName).removeValue()
                    ref.child(cellID).child(newFieldName).setValue(fieldType.rawValue)
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func getStaticTemplate(year: Int, complete: @escaping ([ScoutCell]?, _ error: String?) -> ()){
        if (User.current?.hasTeam)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                let cells = snapshot.children.map{ScoutCell(snapshot: $0 as! DataSnapshot)}
                complete(cells as? [ScoutCell], nil)
            }
        } else {
            complete(nil, "User doesn't have team")
        }
    }
    
}
