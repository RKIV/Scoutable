//
//  ChangeRoboticsTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class ChangeRoboticsTeamController: UIViewController{
    @IBOutlet weak var currentTeamLabel: UILabel!
    @IBOutlet weak var teamTextField: UITextField!
    @IBAction func changeTeamButtonPTapped(_ sender: Any) {
        guard let team = teamTextField.text else {return}
        guard let teamNumber = Int(team) else {return}
        BlueAllianceAPIService.maxTeam{ (max) in
            if teamNumber < max{
                UserService.setRoboticsTeamNumber(as: Int(team)!)
                User.current?.roboticsTeamNumber = teamNumber
                print("set team number")
            }
        }
    }
    
}
