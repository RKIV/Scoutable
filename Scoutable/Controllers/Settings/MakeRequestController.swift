//
//  MakeRequestController.swift
//  Scoutable
//
//  Created by Robert Keller on 8/1/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class MakeRequestController: UIViewController{
    
    @IBOutlet weak var dneLabel: UILabel!
    @IBOutlet weak var requestSentLabel: UILabel!
    @IBOutlet weak var teamTextField: UITextField!
    override func viewDidLoad() {
        super .viewDidLoad()
        requestSentLabel.isHidden = true
        dneLabel.isHidden = true
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        guard let scoutTeam = teamTextField.text,
            !scoutTeam.isEmpty else { return }
        let ref = Database.database().reference()
        //Put in a request to join team
        ref.child("scoutTeams").observeSingleEvent(of: .value){ (teamsSnapshot) in
            if teamsSnapshot.hasChild(scoutTeam){
                ref.child("users").child((User.current?.uid)!).child("requests").observeSingleEvent(of: .value, with: { (requestsSnapshot) in
                    if !requestsSnapshot.hasChild(scoutTeam) && User.current?.scoutTeam != scoutTeam{
                        ScoutTeamServices.makeTeamRequest(to: scoutTeam)
                        self.requestSentLabel.isHidden = false
                        self.dneLabel.isHidden = true
                    } else {
                        self.dneLabel.isHidden = false
                        self.dneLabel.text = "Request already made"
                    }
                })
            }else{
                // TODO: Refresh label for UX
                self.dneLabel.isHidden = false
                self.dneLabel.text = "Team does not exist"
            }
        }
    }
}
