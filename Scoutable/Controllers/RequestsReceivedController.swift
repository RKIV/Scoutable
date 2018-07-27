//
//  RequestsReceivedController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/26/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class RequestsReceivedController: UITableViewController{
    var uidArray = [String]()
    var userArray = [User]()
    override func viewDidLoad() {
        ScoutTeamServices.getRequests { (data, error) in
            if let error = error{ print(error)}
            else{
                self.uidArray = data!
                print(self.uidArray.count)
                for uid in self.uidArray{
                    UserService.show(forUID: uid) { (user) in
                        self.userArray.append(user!)
                        self.tableView.reloadData()
                    }
                }
            }
        }

        
        super .viewDidLoad()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receivedRequestCell") as! ReceievedRequestCellView
        cell.userLabel.text = userArray[indexPath.row].username
        return cell
    }
    
}
