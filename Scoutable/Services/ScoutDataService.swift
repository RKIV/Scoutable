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
    
    static func addStaticTemplateField(_ fieldName: String, fieldType : FieldTypes, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(fieldName){
                    complete("Field Exists")
                } else {
                    ref.child(fieldName).setValue(fieldType.rawValue)
                    complete(nil)
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    
    static func removeStaticTemplateField(_ fieldName: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(fieldName){
                    ref.child(fieldName).removeValue()
                    complete(nil)
                } else {
                    complete("Field Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func editStaticTemplateField(from oldFieldName: String,to newFieldName: String, fieldType: FieldTypes, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(oldFieldName){
                    ref.child(oldFieldName).removeValue()
                    ref.child(newFieldName).setValue(fieldType.rawValue)
                    complete(nil)
                } else {
                    complete("Field Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func getStaticTemplate(year: Int, complete: @escaping ([String : String]?, _ error: String?) -> ()){
        if (User.current?.hasTeam)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child(String(year)).child("static")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String : String]{
                    complete(dict, nil)
                } else {
                    complete(nil, "Snapshot not of correct type")
                }
            }
        } else {
            complete(nil, "User doesn't have team")
        }
    }
    
}
