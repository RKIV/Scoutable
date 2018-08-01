//
//  DynamicTemplateController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/1/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class DynamicTemplateController: UITableViewController{
    @IBOutlet var addCellView: UIView!
    @IBOutlet weak var cellTypePicker: UIPickerView!
    @IBOutlet weak var intialTitleTextField: UITextField!
    var loadedCells: [ScoutTemplateCell]?
    var matchID: String?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        super .viewDidLoad()
        cellTypePicker.dataSource = self
        cellTypePicker.delegate = self
        addCellView.layer.cornerRadius = 6
        loadCells{
            self.tableView.reloadData()
        }
        tableView.keyboardDismissMode = .onDrag
    }
    
    func loadCells(complete: @escaping () ->()){
        ScoutDataService.getDynamicTemplate(year: Int((matchID?.prefix(4))!)!) { (cells, error) in
            if let error = error{
                print(error)
                return
            }
            self.loadedCells = cells
            complete()
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
        ScoutDataService.addDynamicTemplateCell(intialTitleTextField.text!, fieldType: type!, year: Int((matchID?.prefix(4))!)!) { (cellID, error) in
            self.loadedCells?.append(ScoutTemplateCell(cellID: cellID!, type: (type?.rawValue)!, name: self.intialTitleTextField.text!))
            self.tableView.reloadData()
            self.animateAddCellViewOut()
        }
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
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
            cell.templateSwitch.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.NumberPad.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "numpadTemplateCell") as! NumpadTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            cell.numberTextField.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.StepperNumber.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperTemplateCell") as! StepperTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            cell.stepper.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.TextView.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteTemplateCell") as! NoteTemplateCellView
            cell.titleTextField.text = loadedCell.name
            cell.CellID = loadedCell.cellID
            cell.noteTextView.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchTemplateCell") as! SwitchTemplateCellView
            cell.titleTextField.delegate = cell
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Declare Alert message
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
            
            let ghost = UIAlertAction(title: "Ghost", style: .default, handler: { (action) -> Void in
                print("Ghost button tapped")
                ScoutDataService.ghostDynamicTemplateCell(cellID: self.loadedCells![indexPath.row].cellID, year: Int((self.matchID?.prefix(4))!)!, complete: { (error) in
                    if let error = error{
                        print(error)
                    }
                    self.loadCells {
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            })
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
                print("Delete button tapped")
                ScoutDataService.deleteDynamicCells(cellID: self.loadedCells![indexPath.row].cellID, matchID: self.matchID!, complete: { (error) in
                    if let error = error{
                        print(error)
                    }
                    self.loadCells {
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            
            dialogMessage.addAction(ghost)
            dialogMessage.addAction(cancel)
            dialogMessage.addAction(delete)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
}


extension DynamicTemplateController: UIPickerViewDataSource, UIPickerViewDelegate{
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
