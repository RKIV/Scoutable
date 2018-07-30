//
//  NotesTemplateCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class NoteTemplateCellView: UITableViewCell{
    var CellID: String?
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func titleTextFieldEditingEnd(_ sender: Any) {
        ScoutDataService.editStaticTemplateCell(to: titleTextField.text!, cellID: CellID!, year: 2018) { (error) in
            if let error = error{
                print(error)
            }
        }
    }
    
}

extension NoteTemplateCellView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
