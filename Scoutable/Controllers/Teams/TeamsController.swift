//
//  ViewController.swift
//  Scoutable
//
//  Created by Robert Keller on 7/25/18.
//  Copyright © 2018 RKIV. All rights reserved.
//

import UIKit
import SwiftyJSON

class TeamsController: UIViewController {
    
    @IBOutlet weak var logButton: UIBarButtonItem!
    @IBOutlet weak var teamTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private var currentPage = 0
    var teamsArray: [BATeamSimple] = []
    var personalTeam: BATeamSimple?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logButton.title = User.current == nil ? "Log In" : "Log Out"
        if #available(iOS 10.0, *) {
            teamTableView.refreshControl = refreshControl
        } else {
            teamTableView.addSubview(refreshControl)
        }
        teamTableView.refreshControl?.beginRefreshing()
        teamTableView.refreshControl?.addTarget(self, action: #selector(refreshEnd), for: .valueChanged)
        loadTeams{
            print("complete called")
            DispatchQueue.main.async {
                self.teamTableView.reloadData()
                self.teamTableView.refreshControl?.endRefreshing()
            }
        }
        teamTableView.dataSource = self
        teamTableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if let currentUser = User.current{
            UserService.show(forUID: currentUser.uid) { (user) in
                if let user = user{
                    User.setCurrent(user, writeToUserDefaults: true)
                    self.loadPersonalTeam {
                        DispatchQueue.main.async {
                            self.teamTableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func refreshEnd(){
        teamTableView.reloadData()
        teamTableView.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPersonalTeam(complete: @escaping () -> ()){
        if let teamNumber = User.current?.roboticsTeamNumber{
            BlueAllianceAPIService.teamSimple(forNumber: teamNumber) { (teamData) in
                self.personalTeam = teamData
                complete()
            }
        }
    }
    
    func loadTeams(complete: @escaping () -> ()) {
        BlueAllianceAPIService.teamList(page: currentPage) { (data) in
            self.teamsArray += data
            self.currentPage += 1
            if let teamNumber = User.current?.roboticsTeamNumber{
                BlueAllianceAPIService.teamSimple(forNumber: teamNumber) { (teamData) in
                    self.personalTeam = teamData
                     complete()
                }
            } else{
                if (User.current?.uid) != nil{
                    UserService.show(forUID: (User.current?.uid)!, completion: { (user) in
                        if let teamNumber = user?.roboticsTeamNumber{
                            BlueAllianceAPIService.teamSimple(forNumber: teamNumber) { (teamData) in
                                self.personalTeam = teamData
                                complete()
                            }
                        } else {
                            complete()
                        }
                    })
                } else{
                    complete()
                }
            }
        }
    }
    
    @IBAction func logButtonTapped(_ sender: Any) {
        User.logOut()
        let initialViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing")
        let indexPath = teamTableView.indexPathForSelectedRow
        teamTableView.deselectRow(at: indexPath!, animated: true)
        var teamNumber: Int = 0
        var teamName: String = ""
        let teamSimple = teamsArray[(indexPath?.row)!]
        switch indexPath?.section{
        case 0:
            teamNumber = (personalTeam?.team_number)!
            teamName = (personalTeam?.nickname)!
        case 1:
            teamNumber = teamSimple.team_number
            teamName = teamSimple.nickname
        default:
            print("Unexpected section")
        }
        let destination = segue.destination as! IndividualTeamController
        destination.teamNumber = teamNumber
        destination.teamName = teamName
        
    }

}

extension TeamsController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return teamsArray.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            if let teamData = personalTeam{
                let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
                cell.teamName.text = teamData.nickname
                cell.teamNumber.text = String(teamData.team_number)
                cell.teamLocation.text = "\(teamData.city!) \(teamData.state_prov!) \(teamData.country!)"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noPersonalTeamCell") as! NoPersonalTeamCellView
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
            cell.teamName.text = teamsArray[indexPath.row].nickname
            cell.teamNumber.text = String(teamsArray[indexPath.row].team_number)
            cell.teamLocation.text = "\(teamsArray[indexPath.row].city!) \(teamsArray[indexPath.row].state_prov!) \(teamsArray[indexPath.row].country!)"
            return cell
        default:
            print("Unexected section")
            let defaultCell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
            return defaultCell
        }
        
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

