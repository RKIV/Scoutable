//
//  ViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeamsAtEventController: UIViewController {
    
    
    @IBOutlet weak var teamTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    var eventKey: String?
    var teams = [JSON]()
    var rankings =  [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            teamTableView.refreshControl = refreshControl
        } else {
            teamTableView.addSubview(refreshControl)
        }
        teamTableView.refreshControl?.beginRefreshing()
        teamTableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        loadTeams{
            DispatchQueue.main.async {
                self.teamTableView.reloadData()
                self.teamTableView.refreshControl?.endRefreshing()
            }
        }
        teamTableView.dataSource = self
        teamTableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func refreshEnd(){
        teamTableView.reloadData()
        teamTableView.refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadTeams(complete: @escaping () -> ()) {
        BlueAllianceAPIService.rankings(forEvent: eventKey!) { (data) in
            self.rankings = data["rankings"].array!
            let rankingsPure = self.rankings.map{ $0["team_key"].rawString() }
            BlueAllianceAPIService.teams(forEvent: self.eventKey!) { (data) in
                self.teams = data.array!.sorted{(rankingsPure.index(of: $0["key"].rawString()))! < (rankingsPure.index(of: $1["key"].rawString()))!}
                complete()
            }
        }

    }
    
}

extension TeamsAtEventController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! EventTeamCellView
        let record = rankings[indexPath.row]["record"]
        cell.rankLabel.text = rankings[indexPath.row]["rank"].rawString()
        cell.teamNameLabel.text = teams[indexPath.row]["nickname"].rawString()
        cell.teamNumberLabel.text = teams[indexPath.row]["team_number"].rawString()
        cell.recordLabel.text = "\(record["wins"].rawString() ?? "0")-\(record["losses"].rawString() ?? "0")-\(record["ties"].rawString() ?? "0")"
        cell.rankingScoreLabel.text = rankings[indexPath.row]["sort_orders"][0].rawString()
        return cell
    }
}

extension TeamsAtEventController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

