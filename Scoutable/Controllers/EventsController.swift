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
    var eventsArray = [BAEventSimple]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        if User.current?.roboticsTeamNumber == nil {
            performSegue(withIdentifier: "toDistrictList", sender: self)
        }
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            eventsTableView.refreshControl = refreshControl
        } else {
            eventsTableView.addSubview(refreshControl)
        }
        eventsTableView.refreshControl?.beginRefreshing()
        eventsTableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        loadEvents{
            print("complete called")
            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
                self.eventsTableView.refreshControl?.endRefreshing()
            }
        }
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }
    func loadEvents(complete: @escaping () -> ()){
        BlueAllianceAPIService.eventsList(forTeamNumber: (User.current?.roboticsTeamNumber)!) { (eventsData) in
            self.eventsArray = eventsData.reversed()
            complete()
        }
    }
    @objc func refreshEnd(){
        eventsTableView.reloadData()
        eventsTableView.refreshControl?.endRefreshing()
    }
    @IBAction func logButtonPressed(_ sender: Any) {
        User.logOut()
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
        
    }
}

extension EventsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
        cell.nameLabel.text = eventsArray[indexPath.row].name
        cell.locationLabel.text = "\(eventsArray[indexPath.row].city ?? ""), \(eventsArray[indexPath.row].state_prov ?? ""), \(eventsArray[indexPath.row].country ?? "")"
        let formattedStartDate = eventsArray[indexPath.row].start_date.replacingOccurrences(of: "-", with: "/")
        let formattedEndDate = eventsArray[indexPath.row].end_date.replacingOccurrences(of: "-", with: "/")
        cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        return cell
    }
}

extension EventsController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
