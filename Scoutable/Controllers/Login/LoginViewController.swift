//
//  LoginViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: GIDSignInButton!
    var user: GIDGoogleUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = "258126374348-qv2f2p775k1oih4e1jmecl8srmih80mc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // TODO: Add Skip button functionality
    @IBAction func skipButtonTapped(_ sender: Any) {
        let data = NSKeyedArchiver.archivedData(withRootObject: true)
        UserDefaults.standard.set(data, forKey: "isGuestUser")
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? UsernameViewController else { return }
        
        destination.user = user
    }
    
}


extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate{
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing in: \(error.localizedDescription)")
            return
        }
        
        guard let gidUser = user else { return }
        
        UserService.show(forUID: gidUser.userID) { (user) in
            if let user = user {
                User.setCurrent(user, writeToUserDefaults: true)
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
            } else {
                self.user = gidUser
                self.performSegue(withIdentifier: "toCreateUsername", sender: self)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
