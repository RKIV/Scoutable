//
//  UsersController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/1/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class UserController: UITableViewController{
    var users = [User]()
    override func viewDidLoad() {
        super .viewDidLoad()
        ScoutTeamServices.getUsers { (uidArray, error) in
            if let error = error{
                print(error)
            }
            for uid in uidArray{
                UserService.show(forUID: uid) { (user) in
                    self.users.append(user!)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCellView
        cell.usernameLabel.text = users[indexPath.row].username
        cell.uidLabel.text = users[indexPath.row].uid
        cell.isLeaderLabel.text = "Is Leader: \(users[indexPath.row].isLeader)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
