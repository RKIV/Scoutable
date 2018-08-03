//
//  TeamCreationController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TeamCreationController: UIViewController {
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var scoutTeamTextField: UITextField!
    @IBOutlet weak var alreadyExistsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.layer.cornerRadius = 6
        alreadyExistsLabel.isHidden = true
    }
    
    @IBAction func createTapped(_ sender: Any) {
        //Check that there is a client side user and check that the username Text Field is filled in
        guard let scoutTeam = scoutTeamTextField.text,
            !scoutTeam.isEmpty else { return }
        let ref = Database.database().reference()
        ref.child("scoutTeams").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(scoutTeam) {
                // TODO: Refresh label for UX
                self.alreadyExistsLabel.isHidden = false
            } else {
                ScoutTeamServices.create(scoutTeam)
                self.view.endEditing(true)
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
       
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
