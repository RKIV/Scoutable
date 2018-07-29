//
//  StatictTemplateController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/29/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class StaticTemplateController: UITableViewController{
    @IBOutlet var addCellView: UIView!
    @IBOutlet weak var cellTypePicker: UIPickerView!
    @IBOutlet weak var intialTitleTextField: UITextField!
    var loadedCells: [ScoutCell]?
    
    override func viewDidLoad() {
        cellTypePicker.dataSource = self
        cellTypePicker.delegate = self
        addCellView.layer.cornerRadius = 6
        loadCells{
            self.tableView.reloadData()
        }
        super .viewDidLoad()
    }
    
    func loadCells(complete: @escaping () ->()){
        ScoutDataService.getStaticTemplate(year: 2018) { (cells, error) in
            if let error = error{
                print(error)
                return
            }
            self.loadedCells = cells
            
        }
    }
    
    func animateAddCellViewIn(){
        self.view.addSubview(addCellView)
        addCellView.center = self.view.center
        addCellView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addCellView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            //            self.visualEffectView.effect = self.effect
            self.addCellView.alpha = 1
            self.addCellView.transform = CGAffineTransform.identity
        }
    }
    func animateAddCellViewOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.addCellView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addCellView.alpha = 0
            //            self.visualEffectView.effect = nil
        }) { (success) in
            self.addCellView.removeFromSuperview()
        }
    }
    @IBAction func addCellButtonTapped(_ sender: Any) {
        animateAddCellViewIn()
    }
    
    @IBAction func doneButtoneTapped(_ sender: Any) {
        let row = cellTypePicker.selectedRow(inComponent: 0)
        var type: FieldTypes?
        switch row{
        case 0:
            type = FieldTypes.Switch
        case 1:
            type = FieldTypes.StepperNumber
        case 2:
            type = FieldTypes.TextView
        case 3:
            type = FieldTypes.NumberPad
        default:
            print("Unexpected Row")
        }
        ScoutDataService.addStaticTemplateCell(intialTitleTextField.text!, fieldType: type!, year: 2018) { (cellID, error) in
            self.loadedCells?.append(ScoutCell(cellID: cellID!, type: (type?.rawValue)!, name: self.intialTitleTextField.text!))
            self.tableView.reloadData()
            self.animateAddCellViewOut()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadedCells != nil{
            return (loadedCells?.count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let loadedCell = loadedCells![indexPath.row]
        switch loadedCell.type{
        case FieldTypes.Switch.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchTemplateCell") as! SwitchTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            return cell
        case FieldTypes.NumberPad.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "numpadTemplateCell") as! NumpadTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            return cell
        case FieldTypes.StepperNumber.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperTemplateCell") as! StepperTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            return cell
        case FieldTypes.TextView.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteTemplateCell") as! NoteTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchTemplateCell") as! SwitchTemplateCellView
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = loadedCells![indexPath.row].type
        switch type{
        case FieldTypes.Switch.rawValue:
            return 65
        case FieldTypes.StepperNumber.rawValue:
            return 65
        case FieldTypes.TextView.rawValue:
            return 177
        case FieldTypes.NumberPad.rawValue:
            return 65
        default:
            return 65
        }
    }
    
}


extension StaticTemplateController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row{
        case 0:
            return "Switch Field"
        case 1:
            return "Stepper Field"
        case 2:
            return "Notes Field"
        case 3:
            return "Numpad Field"
        default:
            return "Unexpected Row"
        }
    }

    
}
