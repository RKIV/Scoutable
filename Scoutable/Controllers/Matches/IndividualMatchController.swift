//
//  IndividualMatchController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/31/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class IndividualMatchController: UIViewController{
    var matchKey: String?
    var match: JSON?
    var eventKey: String?
    @IBOutlet weak var matchNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var redScoreLabel: UILabel!
    @IBOutlet weak var blueScoreLabel: UILabel!
    @IBOutlet weak var statsTableView: UITableView!
    
    @IBOutlet weak var redOneLabel: UILabel!
    @IBOutlet weak var redTwoLabel: UILabel!
    @IBOutlet weak var redThreeLabel: UILabel!
    @IBOutlet weak var redOneRankLabel: UILabel!
    @IBOutlet weak var redTwoRankLabel: UILabel!
    @IBOutlet weak var redThreeRankLabel: UILabel!
    @IBOutlet weak var blueOneLabel: UILabel!
    @IBOutlet weak var blueTwoLabel: UILabel!
    @IBOutlet weak var blueThreeLabel: UILabel!
    @IBOutlet weak var blueOneRankLabel: UILabel!
    @IBOutlet weak var blueTwoRankLabel: UILabel!
    @IBOutlet weak var blueThreeRankLabel: UILabel!
    @IBOutlet weak var scoutMatchButton: UIButton!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        statsTableView.delegate = self
        statsTableView.dataSource = self
        if User.current != nil && User.current?.scoutTeam != nil{
            scoutMatchButton.isEnabled = true
        } else {
            scoutMatchButton.isEnabled = false
        }
        BlueAllianceAPIService.match(forMatch: matchKey!) { (data) in
            self.match = data
            DispatchQueue.main.async {
                if self.match!["score_breakdown"] == JSON.null{
                }
                self.statsTableView.reloadData()
            }
            BlueAllianceAPIService.rankings(forEvent: self.eventKey!) { (data) in
                let teams = data["rankings"].array
                let redTeamKeys = self.match!["alliances"]["red"]["team_keys"]
                let blueTeamKeys = self.match!["alliances"]["blue"]["team_keys"]
                DispatchQueue.main.async {
                    self.redOneLabel.text = String((redTeamKeys[0].rawString()?.split(separator: "c")[1])!)
                    self.redTwoLabel.text = String((redTeamKeys[1].rawString()?.split(separator: "c")[1])!)
                    self.redThreeLabel.text = String((redTeamKeys[2].rawString()?.split(separator: "c")[1])!)
                    self.blueOneLabel.text = String((blueTeamKeys[0].rawString()?.split(separator: "c")[1])!)
                    self.blueTwoLabel.text = String((blueTeamKeys[1].rawString()?.split(separator: "c")[1])!)
                    self.blueThreeLabel.text = String((blueTeamKeys[2].rawString()?.split(separator: "c")[1])!)
                    self.redOneRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == redTeamKeys[0].rawString()}[0]["rank"].rawValue as! Int)
                    self.redTwoRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == redTeamKeys[1].rawString()}[0]["rank"].rawValue as! Int)
                    self.redThreeRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == redTeamKeys[2].rawString()}[0]["rank"].rawValue as! Int)
                    self.blueOneRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == blueTeamKeys[0].rawString()}[0]["rank"].rawValue as! Int)
                    self.blueTwoRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == blueTeamKeys[1].rawString()}[0]["rank"].rawValue as! Int)
                    self.blueThreeRankLabel.text = String(teams?.filter{$0["team_key"].rawString() == blueTeamKeys[2].rawString()}[0]["rank"].rawValue as! Int)
                    self.redScoreLabel.text = self.match!["alliances"]["red"]["score"].rawString()
                    self.blueScoreLabel.text = self.match!["alliances"]["blue"]["score"].rawString()
                    if self.match!["comp_level"].rawString() == "f"{
                        self.matchNameLabel.text = "Final \(self.match!["match_number"])"
                    } else if self.match!["comp_level"].rawString() == "sf"{
                        self.matchNameLabel.text = "Semifinal \(self.match!["match_number"]).\(self.match!["set_number"])"
                    } else if self.match!["comp_level"].rawString() == "qf"{
                        self.matchNameLabel.text = "Semifinal \(self.match!["match_number"]).\(self.match!["set_number"])"
                    } else {
                        self.matchNameLabel.text = "Qualifier \(self.match!["match_number"])"
                    }
                }
            }
            BlueAllianceAPIService.event(forEventKey: self.eventKey!, done: { (data) in
                DispatchQueue.main.async {
                    self.eventNameLabel.text = "\(data["short_name"].rawString() ?? "Event") -- \(data["district"]["display_name"].rawString() ?? "District")"
                }
            })
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChooseScoutingTeamController
        destination.match = match
        destination.matchKey = matchKey
    }

}

extension IndividualMatchController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let match = match else{return 0}
        if match["score_breakdown"] != JSON.null{
            return match["score_breakdown"]["blue"].count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell") as! StatCellView
        guard let match = match else{
            cell.statTitleLabel.text = "No data available"
            cell.statLabel.text = ""
            return cell
        }
        if match["score_breakdown"] != JSON.null{
            let stat = match["score_breakdown"][(indexPath.section == 0) ? "blue" : "red"].rawValue as! [String : Any]
            cell.statTitleLabel.text = Array(stat.keys)[indexPath.row]
            let value = Array(stat.values)[indexPath.row]
            if let value = value as? String{
                cell.statLabel.text = value
            } else if let value = value as? Int{
                cell.statLabel.text = String(value)
            } else if let value = value as? Bool{
                cell.statLabel.text = String(value)
            } else {
                print("Unexpected type")
            }
        } else {
            cell.statTitleLabel.text = "No data available"
            cell.statLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = "\(section == 0 ? "Blue Team Stats" : "Red Team Stats")"
        v.addSubview(label)
        return v
    }
    
    
    
}
