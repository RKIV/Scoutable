//
//  SettingsController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController{
    @IBOutlet weak var userLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        if User.current != nil{
            userLabel.title = User.current?.username
        } else {
            userLabel.title = "User"
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if User.current == nil{
            return 1
        } else if (User.current?.isLeader)!{
            return 3
        }
        return 2
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toRoboticsTeamChange" && User.current == nil{
            return false
        }
        if identifier == "toRequestsReceived" && !(User.current?.isLeader)!{
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            User.logOut()
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
}
