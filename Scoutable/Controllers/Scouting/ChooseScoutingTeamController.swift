//
//  ChooseScoutingTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/31/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ChooseScoutingTeamController: UITableViewController{
    var match: JSON?
    var redTeams = [JSON]()
    var blueTeams = [JSON]()
    var matchKey: String?
    override func viewDidLoad() {
        super .viewDidLoad()
        redTeams = match!["alliances"]["red"]["team_keys"].array!
        blueTeams = match!["alliances"]["blue"]["team_keys"].array!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "redTeamCell") as! ChooseTeamCellView
            cell.teamNumberLabel.text = String((redTeams[indexPath.row].rawString()?.split(separator: "c")[1])!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blueTeamCell") as! ChooseTeamCellView
            cell.teamNumberLabel.text = String((blueTeams[indexPath.row - 3].rawString()?.split(separator: "c")[1])!)
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DynamicScoutingController
        destination.matchID = matchKey
        destination.teamNumber = (tableView.indexPathForSelectedRow?.row)! < 3 ? Int(String((redTeams[(tableView.indexPathForSelectedRow?.row)!].rawString()?.split(separator: "c")[1])!)) : Int(String((blueTeams[(tableView.indexPathForSelectedRow?.row)! - 3].rawString()?.split(separator: "c")[1])!))
    }
    
    
}
