//
//  EventsController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/27/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EventsController: UITableViewController{
    var districtKey: String?
    var eventsArray = [JSON]()
    var weeks = [Int]()
    
    
    override func viewDidLoad() {
        refreshControl?.beginRefreshing()
        guard let districtID = districtKey else {return}
        BlueAllianceAPIService.eventsList(forDistrict: districtID) { (swiftyData) in
            self.eventsArray = swiftyData.array!
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        
        super .viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if eventsArray.count > 0{
            let sortedByWeek = eventsArray.sorted{$0["week"] < $1["week"]}
            for element in sortedByWeek{
                if !weeks.contains(element["week"].rawValue as! Int){
                    weeks.append(element["week"].rawValue as! Int)
                }
            }
        }
        return weeks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return eventsArray.filter{ $0["week"].rawValue as! Int == weeks[section]}.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekValueArray = eventsArray.filter{ $0["week"].rawValue as! Int == weeks[indexPath.section] }
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCellView
        cell.nameLabel.text = weekValueArray[indexPath.row]["name"].rawValue as? String
        cell.locationLabel.text = "\(weekValueArray[indexPath.row]["city"] ), \(weekValueArray[indexPath.row]["state_prov"] ), \(weekValueArray[indexPath.row]["country"] )"
        let start = weekValueArray[indexPath.row]["start_date"].rawValue as! String
        let startSubstring = start.split(separator: "-")
        let end = weekValueArray[indexPath.row]["end_date"].rawValue as! String
        let endSubstring = end.split(separator: "-")
        let formattedStartDate = "\(startSubstring[1])/\(startSubstring[2])"
        let formattedEndDate = "\(endSubstring[1])/\(endSubstring[2])"
        cell.datesLabel.text = "\(formattedStartDate) - \(formattedEndDate)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TeamsAtEventController
        destination.eventKey = eventsArray[(tableView.indexPathForSelectedRow?.row)!]["key"].rawString()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = "Week \(weeks[section])"
        v.addSubview(label)
        return v
    }
    
}
