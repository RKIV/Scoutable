//
//  ScoutCell.swift
//  Scoutable
//
//  Created by Robert Keller on 7/30/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct ScoutCell{
    var cellID: String?
    var name: String?
    var type: String?
    var boolData: Bool?
    var numberData: Int?
    var textViewData: String?
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String : Any],
        let name = dict["name"] as? String,
        let type = dict["type"] as? String
            else {return nil}
        self.cellID = snapshot.key
        self.name = name
        self.type = type
        switch type{
        case FieldTypes.Switch.rawValue:
            if let value = dict["value"] as? Bool{
                boolData = value
            }
        case FieldTypes.NumberPad.rawValue:
            if let value = dict["value"] as? Int{
                numberData = value
            }
        case FieldTypes.StepperNumber.rawValue:
            if let value = dict["value"] as? Int{
                numberData = value
            }
        case FieldTypes.TextView.rawValue:
            if let value = dict["value"] as? String{
                textViewData = value
            }
        default:
            print("Unexpected field type")
        }
    }
}
