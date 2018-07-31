//
//  IndividualMatchController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/31/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class IndividualMatchController: UIViewController{
    var matchKey: String?
    var match: JSON?
    var eventKey: String?
    @IBOutlet weak var matchNameLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var teamsStackView: UIStackView!
    @IBOutlet weak var redScoreLabel: UILabel!
    @IBOutlet weak var blueScoreLabel: UILabel!
    @IBOutlet weak var statsTableView: UITableView!
    @IBOutlet weak var statsTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        statsTableView.delegate = self
        statsTableView.dataSource = self
        BlueAllianceAPIService.match(forMatch: matchKey!) { (data) in
            self.match = data
            DispatchQueue.main.async {
                if self.match!["score_breakdown"] == JSON.null{
                    self.statsTableViewHeight.constant = CGFloat(208)
                }
                self.statsTableView.reloadData()
                self.statsTableViewHeight.constant = CGFloat(self.match!["score_breakdown"]["blue"].count * 88 + 120)
            }
            var stackViewCount = 0
            BlueAllianceAPIService.rankings(forEvent: self.eventKey!) { (data) in
                let teams = data["rankings"].array
                DispatchQueue.main.async {
                    for stackView in self.teamsStackView.subviews as [UIView] {
                        if let stackView = stackView as? UIStackView{
                            var labelCount = 0
                            for label in stackView.subviews as [UIView]{
                                if let label = label as? UILabel{
                                    if labelCount == 0{
                                        if stackViewCount < 3{
                                            DispatchQueue.main.async {
                                                label.text = self.match!["alliances"]["red"][stackViewCount].rawString()
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                label.text = self.match!["alliances"]["blue"][stackViewCount - 3].rawString()
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            label.text = String(teams?.filter{$0["team_key"].rawString() == self.match!["alliances"][stackViewCount < 3 ? "red" : "blue"]["team_keys"].array![0].rawString()}[0]["rank"].rawValue as! Int)
                                        }
                                    }
                                }
                                labelCount += 1
                            }
                        }
                        stackViewCount += 1
                    }
                }
            }
        }
    }
}

extension IndividualMatchController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let match = match else{return 0}
        if match["score_breakdown"] != JSON.null{
            return match["score_breakdown"]["blue"].count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statCell") as! StatCellView
        guard let match = match else{
            cell.statTitleLabel.text = "No data available"
            cell.statLabel.text = ""
            return cell
        }
        if match["score_breakdown"] != JSON.null{
            let stat = match["score_breakdown"][(indexPath.section == 0) ? "blue" : "red"].rawValue as! [String : Any]
            cell.statTitleLabel.text = Array(stat.keys)[indexPath.row]
            let value = Array(stat.values)[indexPath.row]
            if let value = value as? String{
                cell.statLabel.text = value
            } else if let value = value as? Int{
                cell.statLabel.text = String(value)
            } else if let value = value as? Bool{
                cell.statLabel.text = String(value)
            } else {
                print("Unexpected type")
            }
        } else {
            cell.statTitleLabel.text = "No data available"
            cell.statLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 30))
        v.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 8.0, y: 4.0, width: v.bounds.size.width - 16.0, height: v.bounds.size.height - 8.0))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = "\(section == 0 ? "Blue Team Stats" : "Red Team Stats")"
        v.addSubview(label)
        return v
    }
    
    
    
}
