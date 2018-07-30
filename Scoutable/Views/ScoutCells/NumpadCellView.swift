//
//  NumpadCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class NumpadCellView: UITableViewCell{
    var cellID: String?
    var roboticsTeam: Int?
    @IBOutlet weak var numpadeTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func numpadEditingEnd(_ sender: Any) {
        ScoutDataService.addStaticScoutField(name: titleLabel.text!, type: FieldTypes.NumberPad.rawValue, cellID: cellID!, value: Int(numpadeTextField.text!) ?? 0, roboticsTeam: roboticsTeam!, year: Constants.currentYearConstant, scoutTeam: (User.current?.scoutTeam)!)
    }
}
