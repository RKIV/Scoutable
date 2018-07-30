//
//  File.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ScoutTemplateCell{
    var cellID: String
    var type: String
    var name: String
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String : Any],
            let name = dict["name"] as? String,
            let type = dict["type"] as? String
            else { return nil }
        self.cellID = snapshot.key
        self.name = name
        self.type = type
    }
    
    init(cellID: String, type: String, name: String){
        self.cellID = cellID
        self.name = name
        self.type = type
    }
}
