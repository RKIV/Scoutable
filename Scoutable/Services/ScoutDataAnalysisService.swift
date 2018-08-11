//
//  ScoutDataAnalysisService.swift
//  Scoutable
//
//  Created by Robert Keller on 8/9/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

struct ScoutDataAnalysisService{
    
    //MARK: Single DataAnalysis
    static func createSingleAnalysis(name: String, complete: @escaping (_ name: String?, _ error: String?) -> ()){
        let ref = Database.database().reference().child("scoutTeams").child((User.current?.scoutTeam)!).child("dataAnalysis").child("single")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(name){
                complete(nil, "Analysis alredy exists")
            } else {
                ref.child(name).setValue("")
                complete(name, nil)
            }
        }
    }
}
