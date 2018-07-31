//
//  StaticScoutingController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class StaticScoutingController: UIViewController{
    var teamNumber: Int?
    var regularCells: [ScoutCell]?
    var ghostCells: [ScoutCell]?
    @IBOutlet weak var scoutingTableView: UITableView!
    @IBOutlet weak var editTemplateButton: UIButton!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        if User.current != nil && (User.current?.isLeader)!{
            editTemplateButton.isHidden = false
            editTemplateButton.isUserInteractionEnabled = true
        } else {
            editTemplateButton.isHidden = true
            editTemplateButton.isUserInteractionEnabled = false
        }
        scoutingTableView.dataSource = self
        scoutingTableView.delegate = self
        ScoutDataService.getStaticScoutData(forTeam: teamNumber!, andYear: Constants.currentYearConstant) { (regularCells, ghostCells) in
            self.regularCells = regularCells
            self.ghostCells = ghostCells
            DispatchQueue.main.async {
                self.scoutingTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super . viewWillAppear(animated)
        ScoutDataService.getStaticScoutData(forTeam: teamNumber!, andYear: Constants.currentYearConstant) { (regularCells, ghostCells) in
            self.regularCells = regularCells
            self.ghostCells = ghostCells
            DispatchQueue.main.async {
                self.scoutingTableView.reloadData()
            }
        }
    }
    
}

extension StaticScoutingController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if ghostCells != nil && ghostCells?.count != 0{
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            if regularCells != nil{
                return (regularCells?.count)!
            }
            return 0
        case 1:
            if ghostCells != nil{
                return (ghostCells?.count)!
            }
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var theCell: ScoutCell?
        switch indexPath.section{
        case 0:
            theCell = regularCells![indexPath.row]
        case 1:
            theCell = ghostCells![indexPath.row]
        default:
            print("Section out of index")
            return tableView.dequeueReusableCell(withIdentifier: "switchCell")!
        }
        
        switch theCell?.type{
        case FieldTypes.Switch.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCellView
            cell.titleLabel.text = theCell!.name
            cell.roboticsTeam = teamNumber
            if let switchIsOn = theCell!.boolData{
                cell.switchBool.isOn = switchIsOn
            }
            cell.cellID = theCell!.cellID
            return cell
        case FieldTypes.NumberPad.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "numpadCell") as! NumpadCellView
            cell.titleLabel.text = theCell!.name
            cell.cellID = theCell!.cellID
            cell.roboticsTeam = teamNumber
            if let numData = theCell!.numberData{
                cell.numpadeTextField.text = String(numData)
            }
            return cell
        case FieldTypes.StepperNumber.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepperCell") as! StepperCellView
            cell.titleLabel.text = theCell!.name
            cell.cellID = theCell!.cellID
            cell.roboticsTeam = teamNumber
            if let numData = theCell!.numberData{
                cell.stepperLabel.text = String(numData)
                cell.stepper.value = Double(numData)
            } else {
                cell.stepperLabel.text = "0"
                cell.stepper.value = 0
                cell.textLabel
            }
            return cell
        case FieldTypes.TextView.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteCellView
            cell.titleLabel.text = theCell!.name
            cell.noteTextView.delegate = cell
            cell.cellID = theCell!.cellID
            cell.roboticsTeam = teamNumber
            if let textData = theCell!.textViewData{
                cell.noteTextView.text = textData
            } else {
                cell.noteTextView.text = "Note"
            }
            return cell
        default:
            print("type out of index")
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCellView
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var type: String?
        if indexPath.section == 0{
            type = regularCells![indexPath.row].type
        } else {
            type = ghostCells![indexPath.row].type
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if section == 0{
            label.text = "Template Fields"
        } else {
            label.text = "Ghosted Fields"
        }
        v.addSubview(label)
        return v
    }
    
    
}
