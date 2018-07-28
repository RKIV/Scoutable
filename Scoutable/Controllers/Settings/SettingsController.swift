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
    
    override func viewDidLoad() {
        super .viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (User.current?.isLeader)!{
            print("leader")
            return 2
        }
        print("not so much")
        return 1
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toRequestsReceived" && !(User.current?.isLeader)!{
            return false
        }
        return true
    }
}
