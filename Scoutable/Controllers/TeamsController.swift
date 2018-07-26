//
//  ViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit

class TeamsController: UIViewController {
    
    @IBOutlet weak var teamTableView: UITableView!
    private var currentPage = 0
    var teamsArray: [BATeamSimple] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableView.dataSource = self
        teamTableView.delegate = self
        loadTeams{
            self.teamTableView.reloadData()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTeams(complete: @escaping () -> ()) {
        BLueAllianceAPIService.teamList(page: currentPage) { (data) in
//            print(data.map{$0.team_number})
            self.teamsArray += data
            complete()
            
        }
    }
}

extension TeamsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
        cell.teamName.text = teamsArray[indexPath.row].nickname
        cell.teamNumber.text = String(teamsArray[indexPath.row].team_number)
        cell.teamLocation.text = "\(teamsArray[indexPath.row].city!) \(teamsArray[indexPath.row].state_prov!) \(teamsArray[indexPath.row].country!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = teamsArray.count - 1
        if indexPath.row == lastIndex {
            loadTeams{
                self.teamTableView.reloadData()
            }
        }
    }
}

extension TeamsController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

