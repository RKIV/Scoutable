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
import GoogleSignIn

class IndividualTeamController: UIViewController{
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var eventYearPicker: UIPickerView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var scoutTeamButton: UIButton!
    
    var finals = [JSON]()
    var semifinals = [JSON]()
    var quarterfinals = [JSON]()
    var qualifiers = [JSON]()
    var displayTeamNumber: Int?
    
    // Add this to the VC you want to use it in
    private let refreshControl = UIRefreshControl()
    var teamNumber = 0
    var teamName = ""
    var team: BATeam?
    var eventsArray = [BAEvent]()
    var matches = [JSON]()
    var years = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if User.current != nil && User.current?.scoutTeam != nil{
            scoutTeamButton.isEnabled = true
        } else {
            scoutTeamButton.isEnabled = false
        }
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

            }
        }
        eventYearPicker.delegate = self
        eventYearPicker.dataSource = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
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
    
    func loadTeam(complete: @escaping () -> ()){
        BlueAllianceAPIService.team(forNumber: teamNumber) { (team) in
            self.team = team
        }
        BlueAllianceAPIService.events(forTeamNumber: teamNumber) { (events) in
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
        
        BlueAllianceAPIService.matches(forEvent: eventKey, teamKey: "frc\(teamNumber)") { (data) in
            let dict = ["qm" : 0, "qf" : 1, "sf" : 2, "f" : 3]
            self.matches = (data.array?.sorted{ (first, second) -> Bool in
                if dict[first["comp_level"].rawString()!] ?? 0 == dict[second["comp_level"].rawString()!] ?? 0{
                    if (first["set_number"].rawValue as! Int) == (second["set_number"].rawValue as! Int){
                        if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
                            return true
                        }
                        return false
                    } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
                        return true
                    }
                    return false
                } else if dict[first["comp_level"].rawString()!]! < dict[second["comp_level"].rawString()!]!{
                    return true
                }
                return false
            })!
            complete()
        }
        
    }
    
    @objc func refreshEnd(){
        eventsTableView.reloadData()
        eventsTableView.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! StaticScoutingController
        destination.teamNumber = self.teamNumber
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
            } else if match["comp_level"] == "f"{
                cell.matchNumberLabel.text = "\(match["comp_level"].rawString()?.uppercased() ?? "Q")\(match["match_number"].rawString() ?? "0")"
            } else {
                cell.matchNumberLabel.text = "\(match["comp_level"].rawString()?.uppercased() ?? "Q")\(match["set_number"].rawString() ?? "0").\(match["match_number"].rawString() ?? "0")"
            }
            let blueTeams = match["alliances"]["blue"]["team_keys"]
            let redTeams = match["alliances"]["red"]["team_keys"]
            cell.blueOneLabel.text = String((blueTeams[0].rawString()?.split(separator: "c")[1]) ?? "No Team")
            cell.blueTwoLabel.text = String((blueTeams[1].rawString()?.split(separator: "c")[1]) ?? "No Team")
            cell.blueThreeLabel.text = String((blueTeams[2].rawString()?.split(separator: "c")[1]) ?? "No Team")
            cell.redOneLabel.text = String((redTeams[0].rawString()?.split(separator: "c")[1]) ?? "No Team")
            cell.redTwoLabel.text = String((redTeams[1].rawString()?.split(separator: "c")[1]) ?? "No Team")
            cell.redThreeLabel.text = String((redTeams[2].rawString()?.split(separator: "c")[1]) ?? "No Team")
            
            
            
            if match["actual_time"] != JSON.null{
                let date = NSDate(timeIntervalSince1970: match["actual_time"].rawValue as! Double)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let myString = (String(describing: date))
                let yourDate = formatter.date(from: myString)
                formatter.dateFormat = "HH:mm:ss"
                cell.matchTimeLabel.text = formatter.string(for: yourDate)
            }
            cell.blueScoreLabel.text = match["alliances"]["blue"]["score"].rawString()
            cell.redScoreLabel.text = match["alliances"]["red"]["score"].rawString()
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
        if indexPath.section == 0{
            print(years[eventYearPicker.selectedRow(inComponent: 0)])
            let eventsInYear = eventsArray.filter{$0.year == years[eventYearPicker.selectedRow(inComponent: 0)]}
            loadMatches(eventKey: eventsInYear[indexPath.row].key) {
                print(eventsInYear[indexPath.row].name)
                DispatchQueue.main.async {
                    self.eventsTableView.reloadData()
                }
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
        loadTeam {
            return
        }
        refreshEnd()
    }
}
