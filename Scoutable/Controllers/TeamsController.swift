//
//  ViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit

class TeamsController: UIViewController {
    
    @IBOutlet weak var logButton: UIBarButtonItem!
    @IBOutlet weak var teamTableView: UITableView!
    private var currentPage = 0
    var teamsArray: [BATeamSimple] = Array()
    var personalTeam: BATeamSimple?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableView.dataSource = self
        teamTableView.delegate = self
        loadTeams{
            self.teamTableView.reloadData()
        }
        logButton.title = User.current == nil ? "Log In" : "Log Out"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTeams(complete: @escaping () -> ()) {
        BLueAllianceAPIService.teamList(page: currentPage) { (data) in
            self.teamsArray += data
            complete()
        }
        
        if let teamNumber = User.current?.teamNumber{
            BLueAllianceAPIService.team(forNumber: teamNumber) { (teamData) in
                self.personalTeam = teamData
            }
        }
    }
    
    
    @IBAction func logButtonTapped(_ sender: Any) {
        User.logOut()
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
}

extension TeamsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if User.current?.teamNumber != nil && section == 0{
            return 1
        }
        return teamsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if User.current?.teamNumber != nil{
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
        if let teamData = personalTeam, indexPath.section == 0{
                cell.teamName.text = teamData.nickname
                cell.teamNumber.text = String(teamData.team_number)
                cell.teamLocation.text = "\(teamData.city!) \(teamData.state_prov!) \(teamData.country!)"
        } else {
            cell.teamName.text = teamsArray[indexPath.row].nickname
            cell.teamNumber.text = String(teamsArray[indexPath.row].team_number)
            cell.teamLocation.text = "\(teamsArray[indexPath.row].city!) \(teamsArray[indexPath.row].state_prov!) \(teamsArray[indexPath.row].country!)"
        }
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

