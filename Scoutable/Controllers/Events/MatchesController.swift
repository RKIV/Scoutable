//
//  MatchesController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/31/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MatchesController: UITableViewController{
    @IBOutlet weak var filterButton: UIBarButtonItem!
    var eventKey: String?
    var matches = [JSON]()
    var teamMatches = [JSON]()
    var allMatches = [JSON]()
    var isFilteringByTeamNumber = false
    
    override func viewDidLoad() {
        super .viewDidLoad()
        filterButton.isEnabled = false
        if User.current != nil && User.current?.roboticsTeamNumber != nil{
            BlueAllianceAPIService.teams(forEvent: eventKey!) { (data) in
                let swiftyArray = data.arrayValue.map{$0["team_number"].rawValue as! Int}
                if swiftyArray.contains((User.current?.roboticsTeamNumber)!){
                    DispatchQueue.main.async {
                        self.filterButton.isEnabled = true
                    }
                }
            }
        }
        loadMatches(eventKey: eventKey!) {
            self.loadTeamMatches(eventKey: self.eventKey!, teamNumber: (User.current?.roboticsTeamNumber)!) {
                DispatchQueue.main.async {
                    self.matches = self.allMatches
                    self.tableView.reloadData()
                }
            }

        }

    }
    func loadMatches(eventKey: String, complete: @escaping () ->()){
        BlueAllianceAPIService.matchesSimple(eventKey: eventKey) { (data) in
            let dict = ["qm" : 0, "qf" : 1, "sf" : 2, "f" : 3]
            self.allMatches = (data.array?.sorted{ (first, second) -> Bool in
                if dict[first["comp_level"].rawString()!]! == dict[second["comp_level"].rawString()!]!{
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
    
    func loadTeamMatches(eventKey: String, teamNumber: Int, complete: @escaping () -> ()){
        BlueAllianceAPIService.matches(forEvent: eventKey, teamKey: "frc\(teamNumber)") { (data) in
            let dict = ["qm" : 0, "qf" : 1, "sf" : 2, "f" : 3]
            self.teamMatches = (data.array?.sorted{ (first, second) -> Bool in
                if dict[first["comp_level"].rawString()!]! == dict[second["comp_level"].rawString()!]!{
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
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        if !isFilteringByTeamNumber{
            matches = teamMatches
            isFilteringByTeamNumber = !isFilteringByTeamNumber
        } else {
            matches = allMatches
            isFilteringByTeamNumber = !isFilteringByTeamNumber
        }
        tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.blueOneLabel.text = String((blueTeams[0].rawString()?.split(separator: "c")[1])!)
        cell.blueTwoLabel.text = String((blueTeams[1].rawString()?.split(separator: "c")[1])!)
        cell.blueThreeLabel.text = String((blueTeams[2].rawString()?.split(separator: "c")[1])!)
        cell.redOneLabel.text = String((redTeams[0].rawString()?.split(separator: "c")[1])!)
        cell.redTwoLabel.text = String((redTeams[1].rawString()?.split(separator: "c")[1])!)
        cell.redThreeLabel.text = String((redTeams[2].rawString()?.split(separator: "c")[1])!)
        
        
        
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
    }
    
    
}
