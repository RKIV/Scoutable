//
//  ScoutTeamRequestCellView.swift
//  Scoutable
//
//  Created by Robert Keller on 8/1/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class ScoutTeamRequestCellView: UITableViewCell{
    @IBOutlet weak var scoutTeamLabel: UILabel!
    @IBOutlet weak var isAcceptedLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBAction func joinButtonTapped(_ sender: Any) {
        ScoutTeamServices.joinScoutTeam(forUser: (User.current?.uid)!, scoutTeam: scoutTeamLabel.text!)
    }
    
    
}
