//
//  IndividualTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class IndividualTeamController: UIViewController{
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var eventYearPicker: UIPickerView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var statsSegCtrl: UISegmentedControl!
    private let refreshControl = UIRefreshControl()
    var teamNumber = 0
    var teamName = ""
    var team: BATeam?
    var eventsArray = [BAEventSimple]()
    var years = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNumberLabel.text = String(teamNumber)
        teamNameLabel.text = teamName
        if #available(iOS 10.0, *) {
            eventsTableView.refreshControl = refreshControl
        } else {
            eventsTableView.addSubview(refreshControl)
        }
        eventsTableView.refreshControl?.beginRefreshing()
        eventsTableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        BlueAllianceAPIService.team(forNumber: teamNumber) { (team) in
            self.team = team
        }
        BlueAllianceAPIService.eventsList(forTeamNumber: teamNumber) { (events) in
            self.eventsArray = events.reversed()
            for event in self.eventsArray{
                if !self.years.contains(event.year){
                    self.years.append(event.year)
                } else { continue }
            }
            DispatchQueue.main.async {
                self.eventYearPicker.reloadAllComponents()
                self.eventsTableView.reloadData()
                self.eventsTableView.refreshControl?.endRefreshing()
            }
        }
        eventYearPicker.delegate = self
        eventYearPicker.dataSource = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }
    @objc func refreshEnd(){
        eventsTableView.reloadData()
        eventsTableView.refreshControl?.endRefreshing()
    }
    
}

extension IndividualTeamController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if years.count <= 0{
            return 0
        }
        let eventsInYear = eventsArray.filter{$0.year == years[eventYearPicker.selectedRow(inComponent: 0)]}
        return eventsInYear.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventsInYear = eventsArray.filter{$0.year == years[eventYearPicker.selectedRow(inComponent: 0)]}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
        cell.nameLabel.text = eventsInYear[indexPath.row].name
        cell.locationLabel.text = "\(eventsInYear[indexPath.row].city ?? ""), \(eventsInYear[indexPath.row].state_prov ?? ""), \(eventsInYear[indexPath.row].country ?? "")"
        let formattedStartDate = eventsInYear[indexPath.row].start_date.replacingOccurrences(of: "-", with: "/")
        let formattedEndDate = eventsInYear[indexPath.row].end_date.replacingOccurrences(of: "-", with: "/")
        cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}

extension IndividualTeamController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
}

extension IndividualTeamController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(years[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventsTableView.refreshControl?.beginRefreshing()
        refreshEnd()
    }
}
