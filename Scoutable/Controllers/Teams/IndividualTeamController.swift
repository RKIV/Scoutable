//
//  IndividualTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class IndividualTeamController: UIViewController{
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var eventYearPicker: UIPickerView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    
    var finals = [JSON]()
    var semifinals = [JSON]()
    var quarterfinals = [JSON]()
    var qualifiers = [JSON]()
    var displayTeamNumber: Int?
    
    private let refreshControl = UIRefreshControl()
    var teamNumber = 0
    var teamName = ""
    var team: BATeam?
    var eventsArray = [BAEvent]()
    var matches = [JSON]()
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
        loadTeam {
            DispatchQueue.main.async {
                self.eventYearPicker.reloadAllComponents()
                self.eventsTableView.reloadData()
                self.eventsTableView.refreshControl?.endRefreshing()
                self.tableViewHeightContraint.constant = CGFloat(75 * self.eventsArray.filter{$0.year == self.years[self.eventYearPicker.selectedRow(inComponent: 0)]}.count + 30)
            }
        }
        eventYearPicker.delegate = self
        eventYearPicker.dataSource = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }
    
    func loadTeam(complete: @escaping () -> ()){
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
            complete()

        }
    }
    
    func loadMatches(eventKey: String, complete: @escaping () ->()){
        BlueAllianceAPIService.matchesSimple(eventKey: eventKey) { (swiftyData) in
            self.finals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "f"})!
            self.semifinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "sf"})!
            self.quarterfinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qf"})!
            self.qualifiers = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qm"})!
            self.finals = self.finals.sorted{$0["match_number"] < $1["match_number"]}
            self.semifinals = self.semifinals.sorted(by: { (first, second) -> Bool in
                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
                        return true
                    } else {
                        return false
                    }
                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
                    return true
                } else {
                    return false
                }
            })
            self.quarterfinals = self.quarterfinals.sorted(by: { (first, second) -> Bool in
                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
                        return true
                    } else {
                        return false
                    }
                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
                    return true
                } else {
                    return false
                }
            })
            self.qualifiers = self.qualifiers.sorted{$0["match_number"] < $1["match_number"]}
            self.matches = self.qualifiers.filter{ (match) -> Bool in
                let blueTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                let redTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                if blueTeams.contains("frc\(self.teamNumber)") || redTeams.contains("frc\(self.teamNumber)"){
                    return true
                }
                return false
            }
            self.matches += self.quarterfinals.filter{ (match) -> Bool in
                let blueTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                let redTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                if blueTeams.contains("frc\(self.teamNumber)") || redTeams.contains("frc\(self.teamNumber)"){
                    return true
                }
                return false
            }
            self.matches += self.semifinals.filter{ (match) -> Bool in
                let blueTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                let redTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                if blueTeams.contains("frc\(self.teamNumber)") || redTeams.contains("frc\(self.teamNumber)"){
                    return true
                }
                return false
            }
            self.matches += self.finals.filter{ (match) -> Bool in
                let blueTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                let redTeams = match["alliances"]["blue"]["team_keys"].rawValue as! [String]
                if blueTeams.contains("frc\(self.teamNumber)") || redTeams.contains("frc\(self.teamNumber)"){
                    return true
                }
                return false
            }
            complete()
        }
    }
    
    @objc func refreshEnd(){
        eventsTableView.reloadData()
        eventsTableView.refreshControl?.endRefreshing()
    }
    
}

extension IndividualTeamController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if years.count <= 0{
            return 0
        }
        switch  section {
        case 0:
            let eventsInYear = eventsArray.filter{$0.year == years[eventYearPicker.selectedRow(inComponent: 0)]}
            return eventsInYear.count
        case 1:
            return matches.count
        default:
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let eventsInYear = eventsArray.filter{$0.year == years[eventYearPicker.selectedRow(inComponent: 0)]}
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
            cell.nameLabel.text = eventsInYear[indexPath.row].name
            cell.locationLabel.text = "\(eventsInYear[indexPath.row].city ?? ""), \(eventsInYear[indexPath.row].state_prov ?? ""), \(eventsInYear[indexPath.row].country ?? "")"
            let formattedStartDate = eventsInYear[indexPath.row].start_date.replacingOccurrences(of: "-", with: "/")
            let formattedEndDate = eventsInYear[indexPath.row].end_date.replacingOccurrences(of: "-", with: "/")
            cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell") as! MatchCellView
            let match = matches[indexPath.row]
            if match["comp_level"].rawString() == "qm"{
                cell.matchNumberLabel.text = "Q\(match["match_number"])"
            } else if match["comp_levle"] == "f"{
                cell.matchNumberLabel.text = "\(match["comp_level"].rawString()?.uppercased() ?? "Q")\(match["match_number"].rawString() ?? "0")"
            } else {
                cell.matchNumberLabel.text = "\(match["comp_level"].rawString()?.uppercased() ?? "Q")\(match["set_number"].rawString() ?? "0").\(match["match_number"].rawString() ?? "0")"
            }
            let blueTeams = match["alliances"]["blue"]["team_keys"]
            let redTeams = match["alliances"]["red"]["team_keys"]
            cell.blueOneLabel.text = String((blueTeams[0].rawString()?.split(separator: "c")[1])!)
            cell.blueTwoLabel.text = String((blueTeams[1].rawString()?.split(separator: "c")[1])!)
            cell.blueThreeLabel.text = String((blueTeams[2].rawString()?.split(separator: "c")[1])!)
            cell.redOneLabel.text = String((redTeams[0].rawString()?.split(separator: "c")[1])!)
            cell.redTwoLabel.text = String((redTeams[1].rawString()?.split(separator: "c")[1])!)
            cell.redThreeLabel.text = String((redTeams[2].rawString()?.split(separator: "c")[1])!)
            let date = NSDate(timeIntervalSince1970: match["actual_time"].rawValue as! Double)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = (String(describing: date))
            let yourDate = formatter.date(from: myString)
            formatter.dateFormat = "HH:mm:ss"
            cell.matchTimeLabel.text = formatter.string(for: yourDate)
            cell.blueScoreLabel.text = match["alliances"]["blue"]["score"].rawString()
            cell.redScoreLabel.text = match["alliances"]["red"]["score"].rawString()
            cell.isUserInteractionEnabled = false
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadMatches(eventKey: eventsArray[indexPath.row].key) {
            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
                self.tableViewHeightContraint.constant = CGFloat(75 * (self.eventsArray.filter{$0.year == self.years[self.eventYearPicker.selectedRow(inComponent: 0)]}.count + self.matches.count) + 60)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if section == 0{
            label.text = "Events"
        } else {
            label.text = "Matches"
        }
        v.addSubview(label)
        return v
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
