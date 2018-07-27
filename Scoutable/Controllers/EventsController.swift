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
    var years = [Int]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        loadEvents {
            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
            }
        }
    }
    
    func loadEvents(complete: @escaping () -> ()){
        BlueAllianceAPIService.eventsList(forTeamNumber: (User.current?.roboticsTeamNumber)!) { (eventsData) in
            self.eventsArray = eventsData.reversed()
            for event in self.eventsArray{
                if !self.years.contains(event.year){
                    self.years.append(event.year)
                } else { continue }
            }
            complete()
        }
    }
    
    @objc func refreshEnd(){
        loadEvents {
            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
                self.eventsTableView.refreshControl?.endRefreshing()
            }
        }
        
    }
    
    @IBAction func logButtonPressed(_ sender: Any) {
        User.logOut()
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
        
    }
    
    @IBAction func allEventsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toDistrictList", sender: self)
    }
    
}

extension EventsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if years.count <= 0{
            return 0
        }
        let eventsInYear = eventsArray.filter{$0.year == years[section]}
        return eventsInYear.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventsInYear = eventsArray.filter{$0.year == years[indexPath.section]}
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
        cell.nameLabel.text = eventsInYear[indexPath.row].name
        cell.locationLabel.text = "\(eventsInYear[indexPath.row].city ?? ""), \(eventsInYear[indexPath.row].state_prov ?? ""), \(eventsInYear[indexPath.row].country ?? "")"
        let startSubstring = eventsInYear[indexPath.row].start_date.split(separator: "-")
        let endSubstring = eventsInYear[indexPath.row].end_date.split(separator: "-")
        let formattedStartDate = "\(startSubstring[1])/\(startSubstring[2])"
        let formattedEndDate = "\(endSubstring[1])/\(endSubstring[2])"
        cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        return cell
    }
}

extension EventsController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return years.map{String($0)}
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = String(years[section])
        v.addSubview(label)
        return v
    }
}
