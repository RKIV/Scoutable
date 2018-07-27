//
//  ReceievedRequestCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class ReceievedRequestCellView: UITableViewCell{
    @IBOutlet weak var userLabel: UILabel!
    var associatedUID: String?
    weak var parentTableView: RequestsReceivedController?
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let uid = associatedUID else { return }
        ScoutTeamServices.approveRequest(forUserUID: uid) { (error) in
            if let error = error{
                return print(error)
            }
            self.parentTableView?.dealtWithRequest(fromUID: uid)
        }
        
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
    }
    
}
