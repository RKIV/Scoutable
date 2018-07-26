//
//  LoginViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //On login tap check for access to Firebase AuthUI, set tis controller to the Authorization delegate, and show the Authorization UI
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let authUI = FUIAuth.defaultAuthUI() else { return }
        
        authUI.delegate = self
        
        let authViewController = authUI.authViewController()
        
        present(authViewController, animated: true)
    }
    // TODO: Add Skip button functionality
}

extension LoginViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        //Check if there's an err0r
        if let error = error{
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        //Check for client side user
        guard let user = user else { return }
        //Check if user exists
        UserService.show(forUID: user.uid) { (user) in
            //If the user already has an account set the current user and send to main storyboard
            if let user = user{
                User.setCurrent(user, writeToUserDefaults: true)
                
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                //If it's a new user send to create username view controller
            }else {
                self.performSegue(withIdentifier: "toCreateUsername", sender: self)
            }
        }
    }
}
