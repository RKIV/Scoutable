//
//  ExportSignInController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/7/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import Charts
import SwiftyJSON


class SingleDataAnalysisController: UIViewController{
    @IBOutlet weak var statsTableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var templateFieldsTableView: TemplateFieldsTableView!
    
    var teamNumber: Int?
    var customFields: [ScoutTemplateCell]?
    var baFields: [String]?
    let refreshControl = UIRefreshControl()
    private let folderName = "ScoutableFRCData"
    override func viewDidLoad() {
        super .viewDidLoad()
        statsTableView.dataSource = self
        statsTableView.delegate = self
        templateFieldsTableView.refreshControl = refreshControl
        templateFieldsTableView.refreshControl?.addTarget(self, action: #selector(templateRefreshEnd), for: .valueChanged)
        templateFieldsTableView.dataSource = templateFieldsTableView
        templateFieldsTableView.delegate = templateFieldsTableView
    }
    
    @objc func templateRefreshEnd(){
        templateFieldsTableView.refreshControl?.endRefreshing()
    }
    
    func ensureExistenceOf(spreadsheetWithName name: String){
        GTLRDriveHelper.findSpreadsheet(fileName: name) { (spreadsheet) in
            if let spreadsheet = spreadsheet{
                print("Found spreadsheet")
                GTLRDriveHelper.findFolder(folderName: self.folderName, complete: { (folder) in
                    print(folder ?? "No folder")
                    guard let folder = folder else { return }
                    GTLRDriveHelper.moveFile(fileID: spreadsheet.identifier!, folderID: folder.identifier!, complete: { (movedSpreadsheet) in
                        print(movedSpreadsheet?.parents ?? "No parents")
                    })
                })
            } else {
                GTLRSheetsHelper.createSpreadsheet(title: name) { (spreadsheet) in
                    guard let spreadsheet = spreadsheet else { return }
                    print(spreadsheet)
                    GTLRDriveHelper.findFolder(folderName: self.folderName, complete: { (folder) in
                        print(folder ?? "No folder")
                        guard let folder = folder else { return }
                        GTLRDriveHelper.moveFile(fileID: spreadsheet.spreadsheetId!, folderID: folder.identifier!, complete: { (movedSpreadsheet) in
                            print(movedSpreadsheet?.parents ?? "No parents")
                        })
                    })
                }
            }
        }
    }
    
    func updateBarChart(barChart: BarChartView){
        let entry1 = BarChartDataEntry(x: 1, y: Double(40))
        let entry2 = BarChartDataEntry(x: 2, y: Double(-4))
        let entry3 = BarChartDataEntry(x: 3, y: Double(-15))
        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3], label: "Label")
        
        let data = BarChartData(dataSets: [dataSet])
        
        let labels = ["", "match 1", "match 2", "match 3"]
        dataSet.setColors(.lightGray, .brown, .gray)
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
        barChart.xAxis.granularity = 1
        
        barChart.data = data
        barChart.fitBars = true
        barChart.rightAxis.enabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawAxisLineEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawZeroLineEnabled = true
        barChart.chartDescription?.text = ""
        barChart.notifyDataSetChanged()
    }
    
    func animateTemplateFieldsTableViewIn(){
        self.view.addSubview(templateFieldsTableView)
        templateFieldsTableView.superViewController = self
        templateFieldsTableView.center.y = self.view.center.y - 100
        templateFieldsTableView.center.x = self.view.center.x
        templateFieldsTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        templateFieldsTableView.alpha = 0
        templateFieldsTableView.layer.borderColor = UIColor.gray.cgColor
        templateFieldsTableView.layer.borderWidth = 3.0
        
        UIView.animate(withDuration: 0.4) {
            self.templateFieldsTableView.alpha = 1
            self.templateFieldsTableView.transform = CGAffineTransform.identity
        }
    }
    
    func addCustomAnalysisField(field: ScoutTemplateCell){
        customFields?.append(field)
        return
    }
    
    func addBAAnalysisField(statName: String){
        return
    }
    
    
    
    @IBAction func exportToSheetsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        animateTemplateFieldsTableViewIn()
        templateFieldsTableView.refreshControl?.beginRefreshing()
        BlueAllianceAPIService.events(forYear: Constants.currentYearConstant) { (events) in
            BlueAllianceAPIService.matches(forTeamNumber: 5530, done: { (data) in
                var keys: Dictionary<String, JSON>.Keys?
                for match in data.array!{
                    if match["score_breakdown"] != JSON.null{
                        keys = match["score_breakdown"]["blue"].dictionary?.keys
                        break
                    }
                }
                var keyArray = [String]()
                for key in keys!{
                    keyArray.append(key)
                }
                self.templateFieldsTableView.blueAllainceFields = keyArray
                ScoutDataService.getDynamicTemplate(year: Constants.currentYearConstant) { (activeCells, ghostedCells, error) in
                    if let error = error{
                        print(error)
                        return
                    }
                    self.templateFieldsTableView.activeFields = activeCells
                    self.templateFieldsTableView.ghostedFields = ghostedCells
                    DispatchQueue.main.async {
                        self.templateFieldsTableView.reloadData()
                        self.templateFieldsTableView.refreshControl?.endRefreshing()
                    }
                }
            })
        }
    }
}

extension SingleDataAnalysisController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if customFields != nil {
                return customFields!.count
            }
            return 0
        } else {
            if baFields != nil{
                return baFields!.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell") as! DAFieldCell
        if indexPath.section == 0{
            cell.nameLabel.text = customFields![indexPath.row].name
        } else {
            cell.nameLabel.text = baFields![indexPath.row]
        }
        return cell
    }
    
    
}


class TemplateFieldsTableView: UITableView, UITableViewDataSource, UITableViewDelegate{
    var activeFields: [ScoutTemplateCell]?
    var ghostedFields: [ScoutTemplateCell]?
    var blueAllainceFields: [String]?
    var superViewController: SingleDataAnalysisController?
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if activeFields != nil{
                return activeFields!.count
            }
            return 0
        } else if section == 1 {
            if ghostedFields != nil{
                return ghostedFields!.count
            }
            return 0
        } else {
            if blueAllainceFields != nil{
                return (blueAllainceFields?.count)!
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell") as! DATemplateFieldCell
        if indexPath.section == 0{
            cell.fieldNameLabel.text = activeFields![indexPath.row].name
        } else if indexPath.section == 1{
            cell.fieldNameLabel.text = ghostedFields![indexPath.row].name
        } else {
            cell.fieldNameLabel.text = blueAllainceFields![indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell Tapped")
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success) in
            if indexPath.section == 0{
                self.superViewController?.addCustomAnalysisField(field: self.activeFields![indexPath.row])
            } else if indexPath.section == 0{
                self.superViewController?.addCustomAnalysisField(field: self.ghostedFields![indexPath.row])
            } else {
                self.superViewController?.addBAAnalysisField(statName: self.blueAllainceFields![indexPath.row])
            }
            self.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if section == 0{
            label.text = String("Active Fields")
        } else if section == 1 {
            label.text = String("Ghosted Fields")
        } else {
            label.text = String("Blue Alliance Fields")
        }
        
        v.addSubview(label)
        return v
    }
    
}
