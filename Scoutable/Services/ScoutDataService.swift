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
    
    //MARK: Static
    
    static func addStaticTemplateCell(_ fieldName: String, fieldType : FieldTypes, year: Int, complete: @escaping (_ cellID: String?, _ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("activeCells").childByAutoId()
            ref.updateChildValues(["name" : fieldName, "type" : fieldType.rawValue])
            complete(ref.key, nil)
        } else {
            complete(nil, "User Has No Team or Isn't Leader")
        }
    }
    
    static func ghostStaticTemplateCell(cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("activeCells")
            let ghostRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("ghostedCells")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    let templateCell = ScoutTemplateCell(snapshot: snapshot.childSnapshot(forPath: cellID))
                    ref.child(cellID).removeValue()
                    ghostRef.child(cellID).updateChildValues(["name" : templateCell?.name ?? "Name", "type" : templateCell?.type ?? FieldTypes.Switch.rawValue])
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func deleteStaticCells(cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let dataReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("data").child("static").child(String(year))
            let templateReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("activeCells")
            templateReference.observe(.value) { (templateSnapshot) in
                if templateSnapshot.hasChild(cellID){
                    templateReference.child(cellID).removeValue()
                    dataReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                        for roboticsTeam in dataSnapshot.children.allObjects as! [DataSnapshot]{
                            let cells = roboticsTeam.value as! [String : Any]
                            for cell in cells{
                                if cell.key == cellID{
                                    dataReference.child(roboticsTeam.key).child(cell.key).removeValue()
                                }
                            }
                            complete(nil)
                        }
                    })
                    
                } else {
                    complete("Cell doesn't exist")
                }
            }
        }
    }
    
    static func editStaticTemplateCell(to newFieldName: String, cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("activeCells")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    ref.child(cellID).child("name").setValue(newFieldName)
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }
    
    static func getStaticTemplate(year: Int, complete: @escaping (_ activeCells: [ScoutTemplateCell]?,_ ghostedCells: [ScoutTemplateCell]?, _ error: String?) -> ()){
        if (User.current?.hasTeam)!{
            let scoutTeam = User.current?.scoutTeam
            let activeRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("activeCells")
            let ghostedRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("ghostedCells")
            activeRef.observeSingleEvent(of: .value) { (activeSnapshot) in
                ghostedRef.observeSingleEvent(of: .value, with: { (ghostedSnapshot) in
                    let activeCells = activeSnapshot.children.map{ScoutTemplateCell(snapshot: $0 as! DataSnapshot)}
                    let ghostedCells = ghostedSnapshot.children.map{ScoutTemplateCell(snapshot: $0 as! DataSnapshot)}
                    complete(activeCells as? [ScoutTemplateCell], ghostedCells as? [ScoutTemplateCell], nil)
                })
            }
        } else {
            complete(nil, nil, "User doesn't have team")
        }
    }
    
    
    static func addStaticScoutField(name: String, type: String, cellID: String, value: Any, roboticsTeam: Int, year: Int, scoutTeam: String){
        let dataRef = Database.database().reference().child("scoutTeams").child(scoutTeam).child("data").child("static").child(String(year)).child(String(roboticsTeam)).child(cellID)
        dataRef.updateChildValues(["type" : type as Any, "name" : name as Any, "value" : value])
    }
    
    
    static func getStaticScoutData(forTeam roboticsTeam: Int, andYear year: Int, complete: @escaping (_ regularCells: [ScoutCell], _ ghostCells: [ScoutCell]) -> ()){
        let dataRef = Database.database().reference().child("scoutTeams").child((User.current?.scoutTeam)!).child("data").child("static").child(String(year)).child(String(roboticsTeam))
        let templateRef = Database.database().reference().child("scoutTeams").child((User.current?.scoutTeam)!).child("templates").child("static").child(String(year)).child("activeCells")
        var missingFields = [DataSnapshot]()
        var ghostFields = [DataSnapshot]()
        var matchingFields = [DataSnapshot]()
        var regularCellsToReturn = [ScoutCell]()
        var ghostCellsToReturn = [ScoutCell]()
        
        dataRef.observeSingleEvent(of: .value) { (dataSnapshot) in
            templateRef.observeSingleEvent(of: .value) { (templateSnapshot) in
                let dataFieldKeys = (dataSnapshot.children.allObjects as! [DataSnapshot]).map{$0.key}
                let templateFieldKeys = (templateSnapshot.children.allObjects as! [DataSnapshot]).map{$0.key}
                if dataSnapshot.hasChildren(){
                    matchingFields = (dataSnapshot.children.allObjects as! [DataSnapshot]).filter{templateFieldKeys.contains($0.key)}
                    missingFields = (templateSnapshot.children.allObjects as! [DataSnapshot]).filter{!dataFieldKeys.contains($0.key)}
                    ghostFields = (dataSnapshot.children.allObjects as! [DataSnapshot]).filter{!templateFieldKeys.contains($0.key)}
                } else {
                    missingFields = templateSnapshot.children.allObjects as! [DataSnapshot]
                }
                
                for snapshot in matchingFields{
                    var scoutCell = ScoutCell(snapshot: snapshot)
                    let cellID = snapshot.key
                    let tempDict = templateSnapshot.childSnapshot(forPath: cellID).value as! [String : Any]
                    if scoutCell?.name != tempDict["name"] as? String{
                        dataRef.child(cellID).child("name").setValue(templateRef.child(cellID).value(forKey: "name") as! String)
                        scoutCell?.name = templateRef.child(cellID).value(forKey: "name") as? String
                    }
                    regularCellsToReturn.append(scoutCell!)
                }

                for snapshot in missingFields{
                    if let scoutCell = ScoutCell(snapshot: snapshot){
                        regularCellsToReturn.append(scoutCell)
                    }
                }
                ghostCellsToReturn = ghostFields.map{ScoutCell(snapshot: $0)!}
                complete(regularCellsToReturn, ghostCellsToReturn)
            }

        }
    }
    
    static func deleteStaticGhostedCell(cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let dataReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("data").child("static").child(String(year))
            let templateReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("static").child(String(year)).child("ghostedCells")
            templateReference.observe(.value) { (templateSnapshot) in
                if templateSnapshot.hasChild(cellID){
                    templateReference.child(cellID).removeValue()
                    dataReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                        for roboticsTeam in dataSnapshot.children.allObjects as! [DataSnapshot]{
                            let cells = roboticsTeam.value as! [String : Any]
                            for cell in cells{
                                if cell.key == cellID{
                                    dataReference.child(roboticsTeam.key).child(cell.key).removeValue()
                                }
                            }
                            complete(nil)
                        }
                    })
                    
                } else {
                    complete("Cell doesn't exist")
                }
            }
        }
    
    }
    //MARK: Dynamic

    static func getDynamicTemplate(year: Int, complete: @escaping (_ activeCells: [ScoutTemplateCell]?, _ ghostedCells: [ScoutTemplateCell]?, _ error: String?) -> ()){
        if (User.current?.hasTeam)!{
            let scoutTeam = User.current?.scoutTeam
            let activeRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("activeCells")
            let ghostedRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("ghostedCells")
            activeRef.observeSingleEvent(of: .value) { (activeSnapshot) in
                ghostedRef.observeSingleEvent(of: .value) { (ghostedSnapshot) in
                    let activeCells = activeSnapshot.children.map{ScoutTemplateCell(snapshot: $0 as! DataSnapshot)}
                    let ghostedCells = ghostedSnapshot.children.map{ScoutTemplateCell(snapshot: $0 as! DataSnapshot)}
                    complete(activeCells as? [ScoutTemplateCell], ghostedCells as? [ScoutTemplateCell], nil)
                
                }
            }
        } else {
            complete(nil, nil, "User doesn't have team")
        }
    }
    
    static func addDynamicTemplateCell(_ fieldName: String, fieldType : FieldTypes, year: Int, complete: @escaping (_ cellID: String?, _ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("activeCells").childByAutoId()
            ref.updateChildValues(["name" : fieldName, "type" : fieldType.rawValue])
            complete(ref.key, nil)
        } else {
            complete(nil, "User Has No Team or Isn't Leader")
        }
    }
    
    static func ghostDynamicTemplateCell(cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("activeCells")
            let ghostRef = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("ghostedCells")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    let templateCell = ScoutTemplateCell(snapshot: snapshot.childSnapshot(forPath: cellID))
                    ref.child(cellID).removeValue()
                    ghostRef.child(cellID).updateChildValues(["name" : templateCell?.name ?? "name", "type" : templateCell?.type ?? FieldTypes.Switch.rawValue])
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }

    static func deleteDynamicCells(cellID: String, matchID: String, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let dataReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("data").child("dynamic")
            let templateReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(matchID.prefix(4))).child("activeCells")
            templateReference.observe(.value) { (templateSnapshot) in
                if templateSnapshot.hasChild(cellID){
                    templateReference.child(cellID).removeValue()
                    dataReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                        for roboticsTeam in dataSnapshot.children.allObjects as! [DataSnapshot]{
                            for match in roboticsTeam.children.allObjects as! [DataSnapshot]{
                                if match.key.prefix(4) == matchID.prefix(4){
                                    let cells = match.value as! [String : Any]
                                    for cell in cells{
                                        if cell.key == cellID{
                                            dataReference.child(roboticsTeam.key).child(match.key).child(roboticsTeam.key).child(cell.key).removeValue()
                                        }
                                    }
                                }
                                let cells = match.value as! [String : Any]
                                for cell in cells{
                                    if cell.key == cellID{
                                        dataReference.child(cell.key).removeValue()
                                    }
                                }
                            }
                            complete(nil)
                        }
                    })
                    
                } else {
                    complete("Cell doesn't exist")
                }
            }
        }
    }

    static func editDynamicTemplateCell(to newFieldName: String, cellID: String, year: Int, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let ref = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(year)).child("activeCells")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(cellID){
                    ref.child(cellID).child("name").setValue(newFieldName)
                    complete(nil)
                } else {
                    complete("Cell Doesn't Exist")
                }
            }
        } else {
            complete("User Has No Team or Isn't Leader")
        }
    }

    static func addDynamicScoutField(name: String, type: String, cellID: String, value: Any, roboticsTeam: Int, matchID: String, scoutTeam: String){
        let dataRef = Database.database().reference().child("scoutTeams").child(scoutTeam).child("data").child("dynamic").child(String(roboticsTeam)).child(matchID).child(cellID)
        dataRef.updateChildValues(["type" : type as Any, "name" : name as Any, "value" : value])
    }

    static func getDynamicScoutData(forTeam roboticsTeam: Int, andMatch matchID: String, complete: @escaping (_ regularCells: [ScoutCell], _ ghostCells: [ScoutCell]) -> ()){
        let dataRef = Database.database().reference().child("scoutTeams").child((User.current?.scoutTeam)!).child("data").child("dynamic").child(String(roboticsTeam)).child(matchID)
        let templateRef = Database.database().reference().child("scoutTeams").child((User.current?.scoutTeam)!).child("templates").child("dynamic").child(String(matchID.prefix(4))).child("activeCells")
        var missingFields = [DataSnapshot]()
        var ghostFields = [DataSnapshot]()
        var matchingFields = [DataSnapshot]()
        var regularCellsToReturn = [ScoutCell]()
        var ghostCellsToReturn = [ScoutCell]()
        
        dataRef.observeSingleEvent(of: .value) { (dataSnapshot) in
            templateRef.observeSingleEvent(of: .value) { (templateSnapshot) in
                let dataFieldKeys = (dataSnapshot.children.allObjects as! [DataSnapshot]).map{$0.key}
                let templateFieldKeys = (templateSnapshot.children.allObjects as! [DataSnapshot]).map{$0.key}
                if dataSnapshot.hasChildren(){
                    matchingFields = (dataSnapshot.children.allObjects as! [DataSnapshot]).filter{templateFieldKeys.contains($0.key)}
                    missingFields = (templateSnapshot.children.allObjects as! [DataSnapshot]).filter{!dataFieldKeys.contains($0.key)}
                    ghostFields = (dataSnapshot.children.allObjects as! [DataSnapshot]).filter{!templateFieldKeys.contains($0.key)}
                } else {
                    missingFields = templateSnapshot.children.allObjects as! [DataSnapshot]
                }
                
                for snapshot in matchingFields{
                    var scoutCell = ScoutCell(snapshot: snapshot)
                    let cellID = snapshot.key
                    let tempDict = templateSnapshot.childSnapshot(forPath: cellID).value as! [String : Any]
                    if scoutCell?.name != tempDict["name"] as? String{
                        dataRef.child(cellID).child("name").setValue(templateRef.child(cellID).value(forKey: "name") as! String)
                        scoutCell?.name = templateRef.child(cellID).value(forKey: "name") as? String
                    }
                    regularCellsToReturn.append(scoutCell!)
                }
                
                for snapshot in missingFields{
                    if let scoutCell = ScoutCell(snapshot: snapshot){
                        regularCellsToReturn.append(scoutCell)
                    }
                }
                ghostCellsToReturn = ghostFields.map{ScoutCell(snapshot: $0)!}
                complete(regularCellsToReturn, ghostCellsToReturn)
            }
            
        }
    }

    static func deleteDynamicGhostedCell(cellID: String, matchID: String, complete: @escaping (_ error: String?) -> ()){
        if (User.current?.hasTeam)! && (User.current?.isLeader)!{
            let scoutTeam = User.current?.scoutTeam
            let dataReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("data").child("dynamic")
            let templateReference = Database.database().reference().child("scoutTeams").child(scoutTeam!).child("templates").child("dynamic").child(String(matchID.prefix(4))).child("ghostedCells")
            templateReference.observe(.value) { (templateSnapshot) in
                if templateSnapshot.hasChild(cellID){
                    templateReference.child(cellID).removeValue()
                    dataReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                        for roboticsTeam in dataSnapshot.children.allObjects as! [DataSnapshot]{
                            for match in roboticsTeam.children.allObjects as! [DataSnapshot]{
                                if match.key.prefix(4) == matchID.prefix(4){
                                    let cells = match.value as! [String : Any]
                                    for cell in cells{
                                        if cell.key == cellID{
                                            dataReference.child(roboticsTeam.key).child(match.key).child(cell.key).removeValue()
                                        }
                                    }
                                }
                                let cells = match.value as! [String : Any]
                                for cell in cells{
                                    if cell.key == cellID{
                                        dataReference.child(cell.key).removeValue()
                                    }
                                }
                            }
                            complete(nil)
                        }
                    })
                    
                } else {
                    complete("Cell doesn't exist")
                }
            }
        }
    }
}


