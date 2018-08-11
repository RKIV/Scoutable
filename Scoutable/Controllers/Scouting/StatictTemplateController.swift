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
    var loadedActiveCells: [ScoutTemplateCell]?
    var loadedGhostedCells: [ScoutTemplateCell]?
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        cellTypePicker.dataSource = self
        cellTypePicker.delegate = self
        intialTitleTextField.delegate = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        addCellView.layer.cornerRadius = 6
        loadCells{
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        tableView.keyboardDismissMode = .onDrag
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if let currentUser = User.current{
            UserService.show(forUID: currentUser.uid) { (user) in
                if let user = user{
                    User.setCurrent(user)
                }
            }
        }
    }
    
    @objc func refreshEnd(){
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func loadCells(complete: @escaping () ->()){
        ScoutDataService.getStaticTemplate(year: Constants.currentYearConstant) { (activeCells, ghostedCells, error) in
            if let error = error{
                print(error)
                return
            }
            self.loadedActiveCells = activeCells
            self.loadedGhostedCells = ghostedCells
            complete()
        }
    }
    
    func animateAddCellViewIn(){
        self.view.addSubview(addCellView)
        addCellView.center.y = self.view.center.y - 100
        addCellView.center.x = self.view.center.x
        addCellView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addCellView.alpha = 0
        addCellView.layer.borderColor = UIColor.gray.cgColor
        addCellView.layer.borderWidth = 3.0
        
        UIView.animate(withDuration: 0.4) {
            //            self.visualEffectView.effect = self.effect
            self.addCellView.alpha = 1
            self.tableView.backgroundView?.alpha = 0.5
            self.addCellView.transform = CGAffineTransform.identity
        }
    }
    func animateAddCellViewOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.addCellView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.tableView.backgroundView?.alpha = 1
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
        ScoutDataService.addStaticTemplateCell(intialTitleTextField.text!, fieldType: type!, year: Constants.currentYearConstant) { (cellID, error) in
            self.loadedActiveCells?.append(ScoutTemplateCell(cellID: cellID!, type: (type?.rawValue)!, name: self.intialTitleTextField.text!))
            self.tableView.reloadData()
            self.animateAddCellViewOut()
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        animateAddCellViewOut()
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
         _ = navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if loadedActiveCells != nil{
                return (loadedActiveCells?.count)!
            }
            return 0
        } else {
            if loadedGhostedCells != nil{
                return (loadedGhostedCells?.count)!
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let loadedCell: ScoutTemplateCell?
        if indexPath.section == 0{
            loadedCell = loadedActiveCells![indexPath.row]
        } else{
            loadedCell = loadedGhostedCells![indexPath.row]
        }
        switch loadedCell?.type{
        case FieldTypes.Switch.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchTemplateCell") as! SwitchTemplateCellView
            cell.titleTextField.text = loadedCell?.name
            cell.CellID = loadedCell?.cellID
            cell.templateSwitch.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.NumberPad.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "numpadTemplateCell") as! NumpadTemplateCellView
            cell.titleTextField.text = loadedCell?.name
            cell.CellID = loadedCell?.cellID
            cell.numberTextField.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.StepperNumber.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperTemplateCell") as! StepperTemplateCellView
            cell.titleTextField.text = loadedCell?.name
            cell.CellID = loadedCell?.cellID
            cell.stepper.isUserInteractionEnabled = false
            cell.titleTextField.delegate = cell
            return cell
        case FieldTypes.TextView.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteTemplateCell") as! NoteTemplateCellView
            cell.titleTextField.text = loadedCell?.name
            cell.CellID = loadedCell?.cellID
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
        let type: String?
        if indexPath.section == 0{
            type = loadedActiveCells![indexPath.row].type
        } else {
            type = loadedGhostedCells![indexPath.row].type
        }
        
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
            
            if indexPath.section == 0{
                let dialogMessage = UIAlertController(title: "Confirm", message: "How do you want to delete this?", preferredStyle: .alert)
                
                let ghost = UIAlertAction(title: "Ghost", style: .default, handler: { (action) -> Void in
                    ScoutDataService.ghostStaticTemplateCell(cellID: self.loadedActiveCells![indexPath.row].cellID, year: Constants.currentYearConstant, complete: { (error) in
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
                    ScoutDataService.deleteStaticCells(cellID: self.loadedActiveCells![indexPath.row].cellID, year: Constants.currentYearConstant, complete: { (error) in
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
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                
                dialogMessage.addAction(ghost)
                dialogMessage.addAction(cancel)
                dialogMessage.addAction(delete)
                
                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
            } else {
                let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) -> Void in
                    ScoutDataService.deleteStaticGhostedCell(cellID: self.loadedGhostedCells![indexPath.row].cellID, year: Constants.currentYearConstant, complete: { (error) in
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
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                
                dialogMessage.addAction(cancel)
                dialogMessage.addAction(delete)
                
                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = section == 0 ? "Active Fields" : "Ghosted Fields"
        v.addSubview(label)
        return v
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

extension StaticTemplateController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
