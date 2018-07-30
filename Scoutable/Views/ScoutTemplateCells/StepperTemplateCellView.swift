//
//  StepperTemplateCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class StepperTemplateCellView: UITableViewCell{
    var CellID: String?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        stepperLabel.text = Int(sender.value).description
    }
    
    @IBAction func titleTextFieldEditingEnd(_ sender: Any) {
        ScoutDataService.editStaticTemplateCell(to: titleTextField.text!, cellID: CellID!, year: 2018) { (error) in
            if let error = error{
                print(error)
            }
        }
    }
    
}

extension StepperTemplateCellView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
