//
//  EventsController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class EventsController: UIViewController{
    @IBOutlet weak var eventsTableView: UITableView!
    
    override func viewDidLoad() {
        if User.current == nil {
            performSegue(withIdentifier: "toDistrictList", sender: self)
        }
        super.viewDidLoad()
//        eventsTableView.dataSource = self
    }
    @IBAction func logButtonPressed(_ sender: Any) {
        User.logOut()
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
}

//extension EventsController: UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return
//    }
    
    
//}
