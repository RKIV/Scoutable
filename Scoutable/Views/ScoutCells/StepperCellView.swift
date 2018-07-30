//
//  StepperCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class StepperCellView: UITableViewCell{
    var cellID: String?
    var roboticsTeam: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        stepperLabel.text = Int(sender.value).description
        ScoutDataService.addStaticScoutField(name: titleLabel.text!, type: FieldTypes.StepperNumber.rawValue, cellID: cellID!, value: Int(stepper.value) , roboticsTeam: roboticsTeam!, year: Constants.currentYearConstant, scoutTeam: (User.current?.scoutTeam)!)
    }
}
