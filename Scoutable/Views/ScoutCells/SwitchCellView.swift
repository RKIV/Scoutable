//
//  SwitchCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class SwitchCellView: UITableViewCell{
    var cellID: String?
    var roboticsTeam: Int?
    var dynamic = false
    var matchID: String?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchBool: UISwitch!
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if dynamic {
            ScoutDataService.addDynamicScoutField(name: titleLabel.text!, type: FieldTypes.Switch.rawValue, cellID: cellID!, value: switchBool.isOn, roboticsTeam: roboticsTeam!, matchID: matchID!, scoutTeam: (User.current?.scoutTeam)!)
        } else {
        ScoutDataService.addStaticScoutField(name: titleLabel.text!, type: FieldTypes.Switch.rawValue, cellID: cellID!, value: switchBool.isOn, roboticsTeam: roboticsTeam!, year: Constants.currentYearConstant, scoutTeam: (User.current?.scoutTeam)!)
        }
    }
    
}
