//
//  RequestsSentController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/1/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class RequestsSentController: UITableViewController{
    var requests: [String : Bool]?
    override func viewDidLoad() {
        super .viewDidLoad()
        ScoutTeamServices.getRequestsSent(forUser: (User.current?.uid)!) { (requests) in
            self.requests = requests
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requests != nil{
            return (requests?.count)! + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "currentScoutTeamCell") as! CurrentScoutTeamCell
                if User.current?.scoutTeam != nil{
                    cell.currentScoutTeamLabel.text = "Current Scout Team: \(User.current?.scoutTeam ?? "")"
                } else {
                    cell.currentScoutTeamLabel.text = "No Curent Scout Team"
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "scoutTeamCell") as! ScoutTeamRequestCellView
                cell.scoutTeamLabel.text = Array((requests?.keys)!)[indexPath.row - 1]
                cell.joinButton.isEnabled = Array((requests?.values)!)[indexPath.row - 1] ? true : false
                cell.isAcceptedLabel.text = Array((requests?.values)!)[indexPath.row - 1] ? "Accepted" : "Not Accepted"
                return cell
            }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
