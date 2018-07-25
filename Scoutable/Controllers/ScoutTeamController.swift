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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scoutTeamTextField: UITextField!
    @IBOutlet weak var dneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
        dneLabel.isHidden = true
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        //Check that there is a client side user and check that the username Text Field is filled in
        guard let scoutTeam = scoutTeamTextField.text,
            !scoutTeam.isEmpty else { return }
        let ref = Database.database().reference()
        //Put in a request to joing team
        ref.child("scoutTeams").observeSingleEvent(of: .value){ (snapshot) in
            if snapshot.hasChild(scoutTeam){
                ref.child("scoutTeams").child(scoutTeam).child("users").child(User.current.uid).child("accepted").setValue(false) { (error, _) in
                    if let error = error {
                        print("Team request failed:", error.localizedDescription)
                    }
                    ref.child("users").child(User.current.uid).child("requests").child(scoutTeam).setValue(false) { (error, _) in
                        if let error = error{
                            print("Team request failed:", error.localizedDescription)
                        }
                        //Send to Main storyboard

                    }
                }
            }else{
                self.dneLabel.isHidden = false
            }
        }
    }
    @IBAction func skipButtonPressed(_ sender: Any) {
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    @IBAction func createTeamButtonPressed(_ sender: Any) {
    }
    
    
}
