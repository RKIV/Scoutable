//
//  SelectEvent.swift
//  Scoutable
//
//  Created by Robert Keller on 8/6/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit

class CurrentEventsController: UITableViewController{
    
    var eventsArray = [BAEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        loadEvents{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        loadEvents {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadEvents(complete: @escaping () -> ()){
        BlueAllianceAPIService.eventsList(forYear: Constants.currentYearConstant) { (eventsData) in
            let unfilteredEventsArray = eventsData.reversed()
            self.eventsArray = unfilteredEventsArray.filter({ (event) -> Bool in
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                let startDate = dateFormatter.date(from:event.start_date)!
                let endDate = dateFormatter.date(from:event.end_date)!
                if Date().isBetween(date: startDate, andDate: endDate){
                    return true
                }
                return false
            })
            complete()
        }
    }
    
    @objc func refreshEnd(){
        loadEvents {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SelectMatchController
        destination.eventKey = eventsArray[(tableView.indexPathForSelectedRow?.row)!].key
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventsArray.count != 0{
            return eventsArray.count
        } else {
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if eventsArray.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: "noCurrentEventsCell")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
            cell.nameLabel.text = eventsArray[indexPath.row].name
            cell.locationLabel.text = "\(eventsArray[indexPath.row].city ?? ""), \(eventsArray[indexPath.row].state_prov ?? ""), \(eventsArray[indexPath.row].country ?? "")"
            let startSubstring = eventsArray[indexPath.row].start_date.split(separator: "-")
            let endSubstring = eventsArray[indexPath.row].end_date.split(separator: "-")
            let formattedStartDate = "\(startSubstring[1])/\(startSubstring[2])"
            let formattedEndDate = "\(endSubstring[1])/\(endSubstring[2])"
            cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
            return cell
        }

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if eventsArray.count == 0{
            return 180
        }
        return 75
    }
}

