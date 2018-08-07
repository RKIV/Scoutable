//
//  UsernameController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn

class UsernameViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var teamNumberTextField: UITextField!
    var user: GIDGoogleUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
    }
    
    @IBAction func nextButtonTouched(_ sender: Any) {
        //Check that there is a client side user and check that the username Text Field is filled in
        
        guard let gidUser = user,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        //Create a user on the database
        UserService.create(gidUser, username: username, accessToken: gidUser.authentication.accessToken, completion: {(user) in
            guard let user = user else { return }
            //Set current user
            User.setCurrent(user, writeToUserDefaults: true)
            if let teamNumber = self.teamNumberTextField.text{
                if teamNumber != "" {
                    UserService.setRoboticsTeamNumber(as: Int(teamNumber)!)
                }

            }
            self.view.endEditing(true)
            self.performSegue(withIdentifier: "toTeamSelection", sender: self)
        })
    }
    
    
    
}
