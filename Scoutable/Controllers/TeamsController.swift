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
        loadTeams()
        teamTableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTeams() {
        BLueAllianceAPIService.teamList(page: currentPage) { (data) in
            self.teamsArray += data
        }
    }
}

extension TeamsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
        cell.teamName.text = teamsArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = teamsArray.count - 1
        if indexPath.row == lastIndex {
            loadTeams()
            teamTableView.reloadData()
        }
    }
    
}

extension TeamsController: UITableViewDelegate{
    
}

