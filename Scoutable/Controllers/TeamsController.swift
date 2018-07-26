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
            self.teamTableView.reloadData()
            self.teamTableView.refreshControl?.endRefreshing()
        }
        teamTableView.dataSource = self
        teamTableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func refreshEnd(){
        teamTableView.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadTeams(complete: @escaping () -> ()) {
        BLueAllianceAPIService.teamList(page: currentPage) { (data) in
            self.teamsArray += data
            if let teamNumber = User.current?.roboticsTeamNumber{
                BLueAllianceAPIService.team(forNumber: teamNumber) { (teamData) in
                    self.personalTeam = teamData
                     complete()
                }
            } else{
                if (User.current?.uid) != nil{
                    UserService.show(forUID: (User.current?.uid)!, completion: { (user) in
                        if let teamNumber = user?.roboticsTeamNumber{
                            BLueAllianceAPIService.team(forNumber: teamNumber) { (teamData) in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCellView
        switch indexPath.section{
        case 0:
            if let teamData = personalTeam, indexPath.section == 0{
                cell.teamName.text = teamData.nickname
                cell.teamNumber.text = String(teamData.team_number)
                cell.teamLocation.text = "\(teamData.city!) \(teamData.state_prov!) \(teamData.country!)"
            } else {
                cell.teamName.text = "No personal team"
            }
        case 1:
            cell.teamName.text = teamsArray[indexPath.row].nickname
            cell.teamNumber.text = String(teamsArray[indexPath.row].team_number)
            cell.teamLocation.text = "\(teamsArray[indexPath.row].city!) \(teamsArray[indexPath.row].state_prov!) \(teamsArray[indexPath.row].country!)"
        default:
            print("Unexected section")
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

