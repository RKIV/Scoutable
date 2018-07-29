////
////  IndividualEventController.swift
////  Scoutable
////
////  Created by Robert Keller on 7/27/18.
////  Copyright © 2018 RKIV. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SwiftyJSON
//
//class IndividualEventController: UITableViewController{
//    var finals = [JSON]()
//    var semifinals = [JSON]()
//    var quarterfinals = [JSON]()
//    var qualifiers = [JSON]()
//    var teamNumbers = [Int]()
//    var displayTeamNumber: Int?
//    var eventKey: String?
//    var unplayedMatches: [JSON]?
//
//
//    override func viewDidLoad() {
//        super .viewDidLoad()
//        
//        loadMatches {
//            DispatchQueue.main.async {
//
//                self.tableView.reloadData()
//            }
//        }
//
//
//    }
//    
//    func loadMatches(complete: @escaping () ->()){
//        BlueAllianceAPIService.matchesSimple(eventKey: eventKey!) { (swiftyData) in
//            self.finals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "f"})!
//            self.semifinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "sf"})!
//            self.quarterfinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qf"})!
//            self.qualifiers = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qm"})!
//            self.finals = self.finals.sorted{$0["match_number"] < $1["match_number"]}
//            self.semifinals = self.semifinals.sorted(by: { (first, second) -> Bool in
//                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
//                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
//                        return true
//                    } else {
//                        return false
//                    }
//                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
//                    return true
//                } else {
//                    return false
//                }
//            })
//            self.quarterfinals = self.quarterfinals.sorted(by: { (first, second) -> Bool in
//                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
//                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
//                        return true
//                    } else {
//                        return false
//                    }
//                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
//                    return true
//                } else {
//                    return false
//                }
//            })
//            self.qualifiers = self.qualifiers.sorted{$0["match_number"] < $1["match_number"]}
//            var unplayedMatches = self.qualifiers.filter{$0["winning_alliance"] == JSON.null}
//            unplayedMatches += self.quarterfinals.filter{$0["winning_alliance"] == JSON.null}
//            unplayedMatches += self.semifinals.filter{$0["winning_alliance"] == JSON.null}
//            unplayedMatches += self.finals.filter{$0["winning_alliance"] == JSON.null}
//            self.unplayedMatches = unplayedMatches
//            BlueAllianceAPIService.teams(forEvent: self.eventKey!) { (data) in
//                let teams = data.array!
//                self.teamNumbers = teams.map{$0["team_number"].rawValue as! Int}
//                complete()
//            }
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if teamNumbers.count <= 0{
//            return 0
//        } else if let user = User.current, let team = user.roboticsTeamNumber, teamNumbers.contains(team){
//            return 13
//        }
//        return 7
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if teamNumbers.count <= 0{
//            var teamNumber: Int?
//            if let user = User.current, let team = user.roboticsTeamNumber{
//                teamNumber = team
//            } else if let team = displayTeamNumber{
//                teamNumber = team
//            }
//            if let teamNumber = teamNumber{
//                if indexPath.row == 0{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell") as! SeperatorCellView
//                    cell.seperatorLabel.text = String(teamNumber)
//                    return cell
//                } else if indexPath.row > 0 && indexPath.row < 4{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell")
//
//                } else if indexPath.row == 4{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
//                } else if indexPath.row > 4 && indexPath.row < 8{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell")
//                } else if indexPath.row == 8{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
//                } else if indexPath.row == 9{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell")
//                } else if indexPath.row == 10{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "bracketCell")
//                } else if indexPath.row == 11{
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "teamsCell")
//                } else {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell")
//                }
//            }
//
//
//        } else if let user = User.current, let team = user.roboticsTeamNumber, teamNumbers.contains(team){
//        }
//    }
//}
