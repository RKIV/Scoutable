//
//  ChooseScoutTypeController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/6/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClientForREST
import GoogleSignIn


class ChooseScoutTypeController: UITableViewController, GIDSignInUIDelegate{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if User.current != nil && User.current?.scoutTeam != nil{
            return true
        }
        let dialogMessage = UIAlertController(title: "Unable to perform", message: "Cannot scout without being logged in or without being part of a scout team.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
        return false

    }
}
