//
//  IndividualTeamMatchDelegate.swift
//  Scoutable
//
//  Created by Robert Keller on 7/28/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class IndividualTeamMatchTableView: UITableView{
    var finals = [JSON]()
    var semifinals = [JSON]()
    var quarterfinals = [JSON]()
    var qualifiers = [JSON]()
    var displayTeamNumber: Int?
    var eventKey: String?
    var unplayedMatches: [JSON]?
    
    override func reloadData() {
        super .reloadData()
        loadMatches {
            return
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super .init(frame: frame, style: style)
        number
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadMatches(complete: @escaping () ->()){
        BlueAllianceAPIService.matchesSimple(eventKey: eventKey!) { (swiftyData) in
            self.finals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "f"})!
            self.semifinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "sf"})!
            self.quarterfinals = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qf"})!
            self.qualifiers = (swiftyData.array?.filter{$0["comp_level"].rawString() == "qm"})!
            self.finals = self.finals.sorted{$0["match_number"] < $1["match_number"]}
            self.semifinals = self.semifinals.sorted(by: { (first, second) -> Bool in
                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
                        return true
                    } else {
                        return false
                    }
                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
                    return true
                } else {
                    return false
                }
            })
            self.quarterfinals = self.quarterfinals.sorted(by: { (first, second) -> Bool in
                if first["set_number"].rawValue as! Int == second["set_number"].rawValue as! Int{
                    if (first["match_number"].rawValue as! Int) < (second["match_number"].rawValue as! Int){
                        return true
                    } else {
                        return false
                    }
                } else if (first["set_number"].rawValue as! Int) < (second["set_number"].rawValue as! Int){
                    return true
                } else {
                    return false
                }
            })
            self.qualifiers = self.qualifiers.sorted{$0["match_number"] < $1["match_number"]}
            var unplayedMatches = self.qualifiers.filter{$0["winning_alliance"] == JSON.null}
            unplayedMatches += self.quarterfinals.filter{$0["winning_alliance"] == JSON.null}
            unplayedMatches += self.semifinals.filter{$0["winning_alliance"] == JSON.null}
            unplayedMatches += self.finals.filter{$0["winning_alliance"] == JSON.null}
            self.unplayedMatches = unplayedMatches
            BlueAllianceAPIService.teams(forEvent: self.eventKey!) { (data) in
                let teams = data.array!
                self.teamNumbers = teams.map{$0["team_number"].rawValue as! Int}
                complete()
            }
        }
    }
    
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        <#code#>
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        switch section{
        case 0:
            return qualifiers.filter($0["red"]["team_keys"].array.contains())
        case 1:
            return semifinals.count
        }
    }
}
