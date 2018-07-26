//
//  ScoutTeamController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ScoutTeamController: UIViewController {
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var scoutTeamTextField: UITextField!
    
    
    @IBOutlet weak var dneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestButton.layer.cornerRadius = 6
        dneLabel.isHidden = true
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        //Check that there is a client side user and check that the username Text Field is filled in
        guard let scoutTeam = scoutTeamTextField.text,
            !scoutTeam.isEmpty else { return }
        let ref = Database.database().reference()
        //Put in a request to joing team
        ref.child("scoutTeams").observeSingleEvent(of: .value){ (snapshot) in
            if snapshot.hasChild(scoutTeam){
                ScoutTeamServices.makeTeamRequest(to: scoutTeam)
            }else{
                // TODO: Refresh label for UX
                self.dneLabel.isHidden = false
            }
        }
    }
    // TODO: Add Alert
    @IBAction func skipButtonPressed(_ sender: Any) {
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func createTeamButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toTeamCreation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TeamCreationController
        destination.scoutTeamTextField.text = self.scoutTeamTextField.text
    }
    
    
    
    
}
